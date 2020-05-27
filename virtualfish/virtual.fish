# VirtualFish
# A Virtualenv wrapper for the Fish Shell based on Doug Hellman's virtualenvwrapper

if not set -q VIRTUALFISH_HOME
    set -g VIRTUALFISH_HOME $HOME/.virtualenvs
end

function vf --description "VirtualFish: fish plugin to manage virtualenvs"
    # Check for existence of $VIRTUALFISH_HOME
    if not test -d $VIRTUALFISH_HOME
        echo "The directory $VIRTUALFISH_HOME does not exist."
        echo "Would you like to create it?"
        echo "Tip: To use a different directory, set the variable \$VIRTUALFISH_HOME."
        read -n1 -p "echo 'y/n> '" -l do_create
        if test $do_create = "y"
            mkdir $VIRTUALFISH_HOME
        else
            return 1
        end
    end

    # copy all but the first argument to $scargs
    set -l sc $argv[1]
    set -l funcname "__vf_$sc"
    set -l scargs

    if begin; [ (count $argv) -eq 0 ]; or [ $sc = "--help" ]; or [ $sc = "-h" ]; end
        # If called without arguments, print usage
        vf help
        return
    end

    if test (count $argv) -gt 1
        set scargs $argv[2..-1]
    end

    if functions -q $funcname
        eval $funcname $scargs
    else
        echo "The subcommand $sc is not defined"
    end
end

function __vf_activate --description "Activate a virtualenv"
    # check arguments
    if [ (count $argv) -lt 1 ]
        echo "You need to specify a virtualenv."
        return 1
    end
    if not [ -d $VIRTUALFISH_HOME/$argv[1] ]
        echo "The virtualenv $argv[1] does not exist."
        echo "You can create it with mkvirtualenv."
        return 2
    end

    #Check if a different env is being used
    if set -q VIRTUAL_ENV
        vf deactivate
    end

    # Set VIRTUAL_ENV before the others so that the will_activate event knows
    # which virtualenv is about to be activated
    set -gx VIRTUAL_ENV $VIRTUALFISH_HOME/$argv[1]

    emit virtualenv_will_activate
    emit virtualenv_will_activate:$argv[1]

    set -g _VF_EXTRA_PATH $VIRTUAL_ENV/bin
    set -gx PATH $_VF_EXTRA_PATH $PATH

    # hide PYTHONHOME, PIP_USER
    if set -q PYTHONHOME
        set -g _VF_OLD_PYTHONHOME $PYTHONHOME
        set -e PYTHONHOME
    end
    if set -q PIP_USER
        set -g _VF_OLD_PIP_USER $PIP_USER
        set -e PIP_USER
    end

    # Warn if virtual environment name does not appear in prompt
    if begin; not set -q VIRTUAL_ENV_DISABLE_PROMPT; or test -z "$VIRTUAL_ENV_DISABLE_PROMPT"; end
        if begin; not set -q fish_right_prompt; or not string match -q -- "*$argv[1]*" (eval fish_right_prompt); end
            and not string match -q -- "*$argv[1]*" (eval fish_prompt)
            echo "Virtual environment activated but not shown in shell prompt. To fix, see:"
            echo "<https://virtualfish.readthedocs.io/en/latest/install.html#customizing-your-fish-prompt>"
        end
    end

    emit virtualenv_did_activate
    emit virtualenv_did_activate:(basename $VIRTUAL_ENV)
end

function __vf_deactivate --description "Deactivate this virtualenv"

    if not set -q VIRTUAL_ENV
        echo "No virtualenv is activated."
        return
    end

    emit virtualenv_will_deactivate
    emit virtualenv_will_deactivate:(basename $VIRTUAL_ENV)

    # find elements to remove from PATH
    set to_remove
    for i in (seq (count $PATH))
        if contains -- $PATH[$i] $_VF_EXTRA_PATH
            set to_remove $to_remove $i
        end
    end

    # remove them
    for i in $to_remove
        set -e PATH[$i]
    end

    # restore PYTHONHOME, PIP_USER
    if set -q _VF_OLD_PYTHONHOME
        set -gx PYTHONHOME $_VF_OLD_PYTHONHOME
        set -e _VF_OLD_PYTHONHOME
    end
    if set -q _VF_OLD_PIP_USER
        set -gx PIP_USER $_VF_OLD_PIP_USER
        set -e _VF_OLD_PIP_USER
    end

    emit virtualenv_did_deactivate
    emit virtualenv_did_deactivate:(basename $VIRTUAL_ENV)

    set -e VIRTUAL_ENV
end

function __vfsupport_find_python --description "Search for and return Python path"
    set -l python
    set -l python_arg $argv[1]
    set -l py_version (string replace "python" "" $python_arg)
    set -l brew_path "/usr/local/opt/python@$py_version/bin/python$py_version"
    # Executable on PATH (python3/python3.8) or full interpreter path
    if set -l py_path (command -s $python_arg)
        set python "$py_path"
    # Version number in Homebrew keg-only versioned Python formula
    else if test -x "$brew_path"
        set python "$brew_path"
    # Use `asdf` Python plugin, if found and provided version is available
    else if type -q "asdf"
        set -l asdf_plugins (asdf plugin list)
        if contains python $asdf_plugins
            set -l asdf_path (asdf where python $py_version)/bin/python
            if test -x "$asdf_path"
                set python "$asdf_path"
            end
        end
    # Use Pyenv, if found and provided version is available
    else if type -q "pyenv"
        set -l pyenv_path (pyenv which python$py_version)
        if test -x "$pyenv_path"
            set python "$pyenv_path"
        end
    # Use Pythonz, if found and provided version is available
    else if type -q "pythonz"
        set -l pythonz_path (pythonz locate $py_version)
        if test -x "$pythonz_path"
            set python "$pythonz_path"
        end
    end
    # If no interpreter was found, pass to Virtualenv as-is
    if not test -x "$python"
        set python $python_arg
    end
    echo $python
end

function __vf_new --description "Create a new virtualenv"
    set -l virtualenv_args
    set -l envname

    # Deactivate the current virtualenv, if one is active
    if set -q VIRTUAL_ENV
        vf deactivate
    end

    emit virtualenv_will_create
    argparse -n "vf new" -x q,v,d --ignore-unknown "h/help" "q/quiet" "v/verbose" "d/debug" "p/python=" "c/connect" "V-version" -- $argv

    if set -q _flag_help
        set -l normal (set_color normal)
        set -l green (set_color green)
        echo "Purpose: Creates a new virtual environment"
        echo "Usage: "$green"vf new "(set_color -di)"[-p <python-version>] [--connect] [-q | -v | -d] [-h] [<virtualenv-flags>]"$normal$green" <virtualenv-name>"$normal
        echo
        echo "Examples:"
        echo
        echo $green"vf new -p /usr/local/bin/python3 yourproject"$normal
        echo $green"vf new -p python3.8 --system-site-packages yourproject"$normal
        echo
        echo "To see available "(set_color blue)"Virtualenv"$normal" option flags, run: "$green"virtualenv --help"$normal
        return 0
    end

    if set -q _flag_version
        eval $VIRTUALFISH_PYTHON_EXEC -m virtualenv --version
        return 0
    end

    # Unpack Virtualenv args: first flags that need values, then Boolean flags
    set -l flags_with_args --app-data --discovery --creator --seeder --activators --extra-search-dir --pip --setuptools --wheel --prompt
    while set -q argv[1]
        # If arg starts with a hyphen…
        if string match -q -- "-*" $argv[1]
            # If this option requires a value that we expect to come after it…
            if contains -- $argv[1] $flags_with_args
                # Move both the option flag and its value to a separate list
                set virtualenv_args $virtualenv_args $argv[1] $argv[2]
                set -e argv[2]
            else
                # This option is a Boolean w/o a value. Move to separate list.
                set virtualenv_args $virtualenv_args $argv[1]
            end
        else
            # No hyphen, so this is (hopefully) the new environment's name
            set envname $argv[1]
        end
        set -e argv[1]
    end

    # Ensure a single non-option-flag argument (environment name) was provided
    if test (count $envname) -lt 1
        echo "No virtual environment name was provided."
        return 1
    else if test (count $envname) -gt 1
        echo (set_color red)"Too many arguments. Except for option flags, only virtual environment name is expected:"(set_color normal)
        echo "Virtualenv args: $virtualenv_args"
        echo "Other args: $envname"
        echo
        vf new --help
        return 1
    end

    # Use Python interpreter if provided; otherwise fall back to sane default
    if set -q _flag_python
        set python (__vfsupport_find_python $_flag_python)
    else if set -q VIRTUALFISH_DEFAULT_PYTHON
        set python $VIRTUALFISH_DEFAULT_PYTHON
    else if set -q VIRTUALFISH_PYTHON_EXEC
        set python $VIRTUALFISH_PYTHON_EXEC
    else
        set python python
    end

    if set -q python
        set virtualenv_args "--python" $python $virtualenv_args
    end

    # Virtualenv outputs too much, so we use its quiet mode by default.
    # "--verbose" yields its normal output; "--debug" yields its verbose output
    if not set -q _flag_quiet
        echo "Creating "(set_color blue)"$envname"(set_color normal)" via "(set_color green)"$python"(set_color normal)" …"
    end
    if set -q _flag_debug
        echo "Virtualenv args: $virtualenv_args"
        echo "Other args: $envname"
        echo "Invoking: $VIRTUALFISH_PYTHON_EXEC -m virtualenv $VIRTUALFISH_HOME/$envname $virtualenv_args"
        set virtualenv_args "--verbose" $virtualenv_args
    else if set -q _flag_verbose
        set virtualenv_args $virtualenv_args
    else
        set virtualenv_args "--quiet" $virtualenv_args
    end

    # Use Virtualenv to create the new environment
    set -lx PIP_USER 0
    eval $VIRTUALFISH_PYTHON_EXEC -m virtualenv $VIRTUALFISH_HOME/$envname $virtualenv_args
    set vestatus $status
    if begin; [ $vestatus -eq 0 ]; and [ -d $VIRTUALFISH_HOME/$envname ]; end
        vf activate $envname
        emit virtualenv_did_create
        emit virtualenv_did_create:(basename $VIRTUAL_ENV)
        if set -q _flag_connect
            vf connect
        end
    else
        echo "Error: The virtual environment was not created properly."
        echo "Virtualenv returned status $vestatus."
        return 1
    end
end

function __vf_rm --description "Delete one or more virtual environments"
    if [ (count $argv) -lt 1 ]
        echo "You need to specify at least one virtual environment."
        return 1
    end
    for venv in $argv
        if begin; set -q VIRTUAL_ENV; and [ $venv = (basename $VIRTUAL_ENV) ]; end
            echo "The environment \"$venv\" is active and thus cannot be deleted."
            return 1
        end
        echo "Removing $VIRTUALFISH_HOME/$venv"
        if command -q trash
            command trash $VIRTUALFISH_HOME/$venv
        else
            command rm -rf $VIRTUALFISH_HOME/$venv
        end
    end
end

function __vf_ls --description "List all available virtual environments"
    begin; pushd $VIRTUALFISH_HOME; and set -e dirprev[-1]; end
    for i in */bin/python
        echo $i
    end | sed "s|/bin/python||"
    begin; popd; and set -e dirprev[-1]; end
end

function __vf_cd --description "Change directory to this virtualenv"
    if set -q VIRTUAL_ENV
        cd $VIRTUAL_ENV
    else
        echo "Cannot locate an active virtualenv."
    end
end

function __vf_cdpackages --description "Change to the site-packages directory of this virtualenv"
    if set -q VIRTUAL_ENV
        cd (find $VIRTUAL_ENV -name site-packages -type d | head -n1)
    else
        echo "No virtualenv is active."
    end
end

function __vf_tmp --description "Create a virtualenv that will be removed when deactivated"
    set -l env_name (printf "%s%.4x" "tempenv-" (random) (random) (random))
    vf new $argv $env_name
    set -g VF_TEMPORARY_ENV
end

function __vfsupport_remove_env_on_deactivate_or_exit --on-event virtualenv_did_deactivate --on-process %self
    if set -q VF_TEMPORARY_ENV
        echo "Removing temporary virtualenv" (basename $VIRTUAL_ENV)
        command rm -rf $VIRTUAL_ENV
        set -e VF_TEMPORARY_ENV
    end
end

function __vf_addpath --description "Adds a path to sys.path in this virtualenv"
    if set -q VIRTUAL_ENV
        set -l site_packages (eval "$VIRTUAL_ENV/bin/python -c 'import distutils.sysconfig; print(distutils.sysconfig.get_python_lib())'")
        set -l path_file $site_packages/_virtualenv_path_extensions.pth

        set -l remove 0
        if test $argv[1] = "-d"
            set remove 1
            set -e argv[1]
        end

        if not test -f $path_file
            echo "import sys; sys.__plen = len(sys.path)" > $path_file
            echo "import sys; new=sys.path[sys.__plen:]; del sys.path[sys.__plen:]; p=getattr(sys,'__egginsert',0); sys.path[p:p]=new; sys.__egginsert = p+len(new)" >> $path_file
        end

        for pydir in $argv
            set -l absolute_path (eval "$VIRTUAL_ENV/bin/python -c 'import os,sys; sys.stdout.write(os.path.abspath(\"$pydir\")+\"\n\")'")
            if not test $pydir = $absolute_path
                echo "Warning: Converting \"$pydir\" to \"$absolute_path\"" 1>&2
            end

            if test $remove -eq 1
                sed -i.tmp "\:^$absolute_path\$: d" "$path_file"
            else
                sed -i.tmp '1 a\
'"$absolute_path"'
' "$path_file"
            end
            command rm -f "$path_file.tmp"
        end
        return 0
    else
        echo "No virtualenv is active."
    end
end

function __vf_all --description "Run a command in all virtualenvs sequentially"
    if test (count $argv) -lt 1
        echo "You need to supply a command."
        return 1
    end

    if set -q VIRTUAL_ENV
        set -l old_env (basename $VIRTUAL_ENV)
    end

    for env in (vf ls)
        vf activate $env
        eval $argv
    end

    if set -q old_env
        vf activate $old_env
    else
        vf deactivate
    end
end

# 'vf connect' command
# Used by the project management and auto-activation plugins

if not set -q VIRTUALFISH_ACTIVATION_FILE
    set -g VIRTUALFISH_ACTIVATION_FILE .venv
end

if not set -q VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
    set -g VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE "no-global-site-packages.txt"
end

if not set -q VIRTUALFISH_VENV_CONFIG_FILE
    set -g VIRTUALFISH_VENV_CONFIG_FILE "pyvenv.cfg"
end

function __vf_connect --description "Connect this virtualenv to the current directory"
    if set -q VIRTUAL_ENV
        basename $VIRTUAL_ENV > $VIRTUALFISH_ACTIVATION_FILE
        emit virtualenv_did_connect
        emit virtualenv_did_connect:(basename $VIRTUAL_ENV)
    else
        echo "No virtualenv is active."
    end
end

function __vf_help --description "Print VirtualFish usage information"
    echo "VirtualFish $VIRTUALFISH_VERSION"
    echo
    echo "Usage: vf <command> [<args>]"
    echo
    echo "Available commands:"
    echo
    for sc in (functions -a | sed -n '/__vf_/{s///g;p;}')
        set -l helptext (functions "__vf_$sc" | grep '^function ' | head -n 1 | sed -E "s|.*'(.*)'.*|\1|")
        printf "    %-15s %s\n" $sc (set_color 555)$helptext(set_color normal)
    end
    echo

    if set -q VIRTUALFISH_VERSION
        set help_url "https://virtualfish.readthedocs.org/en/$VIRTUALFISH_VERSION/"
    else
        set help_url "https://virtualfish.readthedocs.org/en/latest/"
    end
    echo "For full documentation, see: $help_url"
end

function __vf_globalpackages --description "Toggle global site packages"
    set -l enabled
    if set -q VIRTUAL_ENV
        pushd $VIRTUAL_ENV
        # If pyvenv.cfg is present, toggle configuration value therein.
        # <https://www.python.org/dev/peps/pep-0405/#isolation-from-system-site-packages>
        # Otherwise use legacy no-global-site-package.txt file in lib/python*/
        if test -e $VIRTUALFISH_VENV_CONFIG_FILE  # PEP 405
            # toggle
            command sed -i '/include-system-site-packages/ {s/true/false/;t;s/false/true/}' \
                $VIRTUALFISH_VENV_CONFIG_FILE
            # read new state
            if [ "true" = (command sed -n 's/include-system-site-packages\s=\s\(true\|false\)/\1/p' \
                $VIRTUALFISH_VENV_CONFIG_FILE) ]
                set enabled 0
            else
                set enabled 1
            end
        else  # legacy
            # use site-packages/.. to avoid ending up in python-wheels
            pushd $VIRTUAL_ENV/lib/python*/site-packages/..
            if test -e $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
                command rm $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
                set enabled 0
            else
                touch $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
                set enabled 1
            end
            popd
        end
        if [ $enabled -eq 0 ]
            echo "Global site packages enabled"
        else
            echo "Global site packages disabled"
        end
        popd
    else
        echo "Cannot toggle global site packages without an active virtual environment."
    end
end

################
# Autocomplete
# Based on https://github.com/zmalltalker/fish-nuggets/blob/master/completions/git.fish
function __vfsupport_setup_autocomplete --on-event virtualfish_did_setup_plugins
    function __vfcompletion_needs_command
        set cmd (commandline -opc)
            if test (count $cmd) -eq 1 -a $cmd[1] = 'vf'
            return 0
        end
        return 1
    end

    function __vfcompletion_using_command
        set cmd (commandline -opc)
        if test (count $cmd) -gt 1
            if test $argv[1] = $cmd[2]
                return 0
            end
        end
        return 1
    end

    # add completion for subcommands
    for sc in (functions -a | sed -n '/__vf_/{s///g;p;}')
        set -l helptext (functions "__vf_$sc" | grep -m1 "^function" | sed -E "s|.*'(.*)'.*|\1|")
        complete -x -c vf -n '__vfcompletion_needs_command' -a $sc -d $helptext
    end

    complete -x -c vf -n '__vfcompletion_using_command activate' -a "(vf ls)"
    complete -x -c vf -n '__vfcompletion_using_command rm' -a "(vf ls)"
end

function __vfsupport_get_default_python --description "Return Python interpreter defined in variables, if any"
    set -l python
    if set -q VIRTUALFISH_PYTHON_EXEC
        set python $VIRTUALFISH_PYTHON_EXEC
    else if set -q VIRTUALFISH_DEFAULT_PYTHON
        set python $VIRTUALFISH_DEFAULT_PYTHON
    else
        set python python
    end
    echo $python
end

function __vf_install --description "Install VirtualFish"
    echo "VirtualFish is already installed! Hooray! To install extra plugins, use the addplugins command."
    return 0
end

function __vf_uninstall --description "Uninstall VirtualFish"
    set -l python (__vfsupport_get_default_python)
    $python -m virtualfish.loader.installer uninstall
    echo "VirtualFish has been uninstalled from this shell."
    echo "Run 'exec fish' to reload Fish."
    echo "Note that the Python package will still be installed and needs to be removed separately (e.g. using 'pip uninstall virtualfish')."
end

function __vf_addplugins --description "Install one or more plugins"
    if test (count $argv) -lt 1
        echo "Provide a plugin to add"
        return -1
    end
    set -l python (__vfsupport_get_default_python)
    $python -m virtualfish.loader.installer addplugins $argv
end

function __vf_rmplugins --description "Remove one or more plugins"
    if test (count $argv) -lt 1
        echo "Provide a plugin to remove"
        return -1
    end
    set -l python (__vfsupport_get_default_python)
    $python -m virtualfish.loader.installer rmplugins $argv
end
