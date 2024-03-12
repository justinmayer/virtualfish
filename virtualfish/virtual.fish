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
        echo "You can create it with `vf new $argv[1]`."
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
    set venv_name (basename "$VIRTUAL_ENV")
    if begin; not set -q VIRTUAL_ENV_DISABLE_PROMPT; or test -z "$VIRTUAL_ENV_DISABLE_PROMPT"; end
        if begin; not set -q fish_right_prompt; or not string match -q -- "*$venv_name*" (eval fish_right_prompt); end
            and not string match -q -- "*$venv_name*" (eval fish_prompt)
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
    # Use `asdf` Python plugin, if found and provided version is available
    else if type -q "asdf"
        set -l asdf_plugins (asdf plugin list)
        if contains python $asdf_plugins
            set -l asdf_path (asdf where python $py_version)/bin/python
            if command -q "$asdf_path"
                set python "$asdf_path"
            end
        end
    # Use Pyenv, if found and provided version is available
    else if type -q "pyenv"
        if test -n "$PYENV_ROOT"
            set pyenv_path "$PYENV_ROOT"/versions/"$py_version"/bin/python
        else
            # If $PYENV_ROOT hasn't been set, assume versions are stored in ~/.pyenv
            set pyenv_path "$HOME"/.pyenv/versions/"$py_version"/bin/python
        end
        if command -q "$pyenv_path"
            set python "$pyenv_path"
        end
    # Use Pythonz, if found and provided version is available
    else if type -q "pythonz"
        set -l pythonz_path (pythonz locate $py_version)
        if command -q "$pythonz_path"
            set python "$pythonz_path"
        end
    # Version number in Homebrew keg-only versioned Python formula
    else if command -q "$brew_path"
        set python "$brew_path"
    end
    # If no interpreter was found, pass to Virtualenv as-is
    if begin; not command -q "$python"; or not __vfsupport_check_python "$python"; end
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
    else
        set python (__vfsupport_get_default_python)
    end

    if set -q python
        set virtualenv_args "--python" $python $virtualenv_args
    end

    # Virtualenv outputs too much, so we use its quiet mode by default.
    # "--verbose" yields its normal output; "--debug" yields its verbose output
    if not set -q _flag_quiet
        # Replace $HOME, if present in Python path, with "~"
        set -l realhome ~
        set -l python_path (string replace -r '^'"$realhome"'($|/)' '~$1' $python)
        echo "Creating "(set_color blue)"$envname"(set_color normal)" via "(set_color green)"$python_path"(set_color normal)" …"
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
        emit virtualenv_will_remove
        emit virtualenv_will_remove:$venv
        if command -q trash
            command trash $VIRTUALFISH_HOME/$venv
        else
            command rm -rf $VIRTUALFISH_HOME/$venv
        end
        emit virtualenv_did_remove
        emit virtualenv_did_remove:$venv
    end
end

function __vf_ls --description "List all available virtual environments"
    argparse -n "vf ls" "h/help" "d/details" -- $argv
    set -l normal (set_color normal)
    set -l green (set_color green)
    set -l red (set_color red)
    if set -q _flag_help
        echo
        echo "Purpose: List existing virtual environments"
        echo "Usage: "$green"vf ls "(set_color -di)"[--details]"$normal
        echo
        echo "Add "$green"--details"$normal" to see per-environment Python version numbers"\n
        return 0
    end
    begin; pushd $VIRTUALFISH_HOME; and set -e dirprev[-1]; end
    # If passed --details, determine default Python version number
    set -l default_python_version
    if set -q _flag_details
        set -l default_python (__vfsupport_get_default_python)
        __vfsupport_check_python $default_python
        if test $status -eq 0
            set default_python_version ($default_python -V | string split " ")[2]
        else
            echo "Could not determine default Python. Add interpreter to Fish config via something like:"
            echo $green\n"set -g VIRTUALFISH_DEFAULT_PYTHON /path/to/valid/bin/python"$normal\n
            return -1
        end
    end
    # Iterate over environments, showing colored version numbers if passed --details
    for p in */bin/python
        if set -q _flag_details
            set -l env_python_version
            # Check whether environment's Python is busted
            __vfsupport_check_python --pip "$VIRTUALFISH_HOME/$p"
            if test $status -eq 0
                set env_python_version ("$VIRTUALFISH_HOME/$p" -V | string split " ")[2]
                # If ASDF tool version list is available, retrieve specified Python versions
                if test -e ~/.tool-versions
                    set python_versions (cat ~/.tool-versions | grep python | sed "s|python ||")
                end
                # If preferred Python versions are specified in ASDF tool version list,
                # display in green if current env's Python matches one of those versions (else yellow).
                if test -n "$python_versions"
                    if string match --entire --quiet "$env_python_version" "$python_versions"
                        set env_python_version $green$env_python_version$normal
                    else
                        set env_python_version (set_color yellow)$env_python_version$normal
                    end
                # Otherwise, infer default Python version and compare to that
                else
                    __vfsupport_compare_py_versions $env_python_version $default_python_version
                    if test $status -eq 1
                        set env_python_version (set_color yellow)$env_python_version$normal
                    else
                        set env_python_version $green$env_python_version$normal
                    end
                end
            else
                set env_python_version $red"broken"$normal
            end
            printf "%-33s %s\n" $p $env_python_version
        else
            # No --details flag, so just print the virtual environment names
            echo $p
        end
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
    and set -g _VF_TEMPORARY_ENV $env_name
end

function __vfsupport_remove_env_on_deactivate_or_exit --on-event virtualenv_did_deactivate --on-process %self
    if begin; set -q _VF_TEMPORARY_ENV; and [ $_VF_TEMPORARY_ENV = (basename $VIRTUAL_ENV) ]; end
        echo "Removing temporary virtualenv" $_VF_TEMPORARY_ENV
        if command -q trash
            command trash $VIRTUAL_ENV
        else
            command rm -rf $VIRTUAL_ENV
        end
        set -e _VF_TEMPORARY_ENV
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
        echo (set_color blue)$env(set_color normal) ➤ Running: (set_color green)$argv(set_color normal) …
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
    set -l normal (set_color normal)
    set -l green (set_color green)
    set -l red (set_color red)

    if test (count $argv) -gt 1
        echo "Usage: "$green"vf connect [<envname>]"$normal
        return 1
    end

    test (count $argv) -eq 0; or vf activate $argv[1]

    if set -q VIRTUAL_ENV
        basename $VIRTUAL_ENV > $VIRTUALFISH_ACTIVATION_FILE
        emit virtualenv_did_connect
        emit virtualenv_did_connect:(basename $VIRTUAL_ENV)
    else
        echo $red"Cannot connect without an active virtual environment."$normal
        return 1
    end
end

function __vf_upgrade --description "Upgrade virtualenv(s) to newer Python version"
    argparse -n "vf upgrade" "h/help" "p/python=" "r/rebuild" "a/all" -- $argv
    set -l python
    set -l venv_list
    set -l normal (set_color normal)
    set -l green (set_color green)

    if set -q _flag_help
        echo
        echo "Purpose: Upgrades existing virtual environment(s)"
        echo "Usage: "$green"vf upgrade "(set_color -di)"[--rebuild] [--python <path/version>] [--all] <env name(s)>"$normal
        echo
        echo "Examples:"
        echo
        echo (set_color -di)"# Upgrade active virtual environment to current default Python version"$normal
        echo $green"vf upgrade"$normal
        echo (set_color -di)"# Rebuild env1 & env2 using Python 3.8.5 via asdf, pyenv, or Pythonz"$normal
        echo $green"vf upgrade --rebuild --python 3.8.5 env1 env2"$normal\n
        return 0
    end

    # Use Python interpreter if provided; otherwise fall back to sane default
    if set -q _flag_python
        set python (__vfsupport_find_python $_flag_python)
    else
        set python (__vfsupport_get_default_python)
    end
    __vfsupport_check_python $python
    if test $status -ne 0
        echo "Specified (or default) Python interpreter does appear to be valid."
        return -1
    end
    # Set envs to upgrade: all, a list of virtualenvs, or current environment
    if set -q _flag_all
        set venv_list (vf ls)
    else if test (count $argv) -gt 0
        set venv_list $argv
    else if set -q VIRTUAL_ENV
        set venv_list (basename $VIRTUAL_ENV)
    else
        echo "No environment activated or specified."
        return 1
    end
    for venv in $venv_list
        set -l packages
        set -l venv_path "$VIRTUALFISH_HOME/$venv"

        emit virtualenv_will_upgrade
        emit virtualenv_will_upgrade:$venv

        __vfsupport_check_python --pip "$venv_path/bin/python"
        if test $status -ne 0
            echo (set_color red)"$venv is broken. Rebuilding…"(set_color normal)
            for p in $venv_path/lib/python3.*/site-packages/*.dist-info
                set packages $packages (string replace "-" "==" (string replace ".dist-info" "" (basename $p)))
            end
        end
        # Re-build if (1) --rebuild passed or (2) above check yields broken env
        if begin; set -q _flag_rebuild; or test -n "$packages"; end
            set -l install_cmd
            set -l linked_project
            # Install via poetry.lock if found; otherwise Pip-install packages
            if begin; set -q PROJECT_HOME; and test -f "$PROJECT_HOME/$venv/poetry.lock"; end
                set install_cmd "poetry install"
            else
                # If broken env, use above package list. Otherwise use `pip freeze`.
                if test -z "$packages"
                    set packages ($venv_path/bin/pip freeze)
                end
                set install_cmd "if test -n '$packages'; pip install -U $packages; end"
            end
            if set -q VIRTUAL_ENV
                vf deactivate
            end
            # If environment contains a .project file, save its contents before removing
            if test -e $venv_path/.project
                set linked_project (cat $venv_path/.project)
            end
            vf rm $venv
            and vf new -p $python $venv
            and eval $install_cmd
            # If environment contained a .project file, restore its contents
            if set -q project_file_path[1]
                echo $linked_project > $venv_path/.project
            end
        else
            # Minor upgrade, so modify existing env's symlinks & version numbers
            # Get full version numbers for both old and new Python interpreters
            set -l old_py_fv ($venv_path/bin/python -V | string split " ")[2]
            set -l new_py_fv ($python -V | string split " ")[2]
            # Get and compare *major* version numbers (e.g., 3.8, 3.9)
            set -l old_py_sv (string split . $old_py_fv)
            set -l new_py_sv (string split . $new_py_fv)
            set -l old_py_mv "$old_py_sv[1].$old_py_sv[2]"
            set -l new_py_mv "$new_py_sv[1].$new_py_sv[2]"
            # If major version numbers don't match, exit without upgrading
            if test "$old_py_mv" -ne "$new_py_mv"
                echo "Not upgrading $venv ($old_py_fv) to $new_py_fv. Add '--rebuild' for major version upgrades."
            else
                # Update symlinks & version numbers
                echo "Upgrading $venv from $old_py_fv to $new_py_fv"
                if [ -L "$venv_path/bin/python" ]; command rm "$venv_path/bin/python"; end
                command ln -s "$python$new_py_mv" "$venv_path/bin/python"
                if [ -L "$venv_path/bin/python3" ]; command rm "$venv_path/bin/python3"; end
                command ln -s "$python$new_py_mv" "$venv_path/bin/python3"
                if [ -L "$venv_path/bin/python$old_py_mv" ]; command rm "$venv_path/bin/python$old_py_mv"; end
                command ln -s "$python$new_py_mv" "$venv_path/bin/python$new_py_mv"
                if test -f "$venv_path/pyvenv.cfg"
                    command sed -i -e "s/$old_py_fv/$new_py_fv/g" "$venv_path/pyvenv.cfg"
                end
                # Clear caches
                command find "$venv_path" -name "__pycache__" -type d -print0|xargs -0 rm -r --
                if begin; set -q PROJECT_HOME; and test -d "$PROJECT_HOME/$venv"; end
                    command find "$PROJECT_HOME/$venv" -name "__pycache__" -type d -print0|xargs -0 rm -r --
                    command find "$PROJECT_HOME/$venv" -name ".pytest_cache" -type d -print0|xargs -0 rm -r --
                end
            end
        end
        emit virtualenv_did_upgrade
        emit virtualenv_did_upgrade:$venv
    end
end

function __vf_help --description "Print VirtualFish usage information"
    echo "VirtualFish $VIRTUALFISH_VERSION"
    echo
    echo "Usage: vf <command> [<args>]"
    echo
    echo "Available commands:"
    echo

    # Dynamically calculate column spacing, based on longest subcommand
    set -l subcommands (functions -a | sed -n '/__vf_/{s///g;p;}')
    set -l max_subcommand_length 0
    for sc in $subcommands
        set -l cur (string length $sc)
        if test $cur -ge $max_subcommand_length
            set max_subcommand_length $cur
        end
    end
    set -l spacing (math $max_subcommand_length + 1)

    for sc in $subcommands
        set -l helptext (functions "__vf_$sc" | grep '^function ' | head -n 1 | sed -E "s|.*'(.*)'.*|\1|")
        printf "    %-$spacing""s %s\n" $sc (set_color 555)$helptext(set_color normal)
    end
    echo

    if set -q VIRTUALFISH_VERSION
        set help_url "https://virtualfish.readthedocs.org/en/$VIRTUALFISH_VERSION/"
    else
        set help_url "https://virtualfish.readthedocs.org/en/latest/"
    end
    echo "For full documentation, see: $help_url"
end

function __vf_globalpackages --description "Manage global site packages"
    argparse --stop-nonopt --ignore-unknown --name "vf globalpackages" "h/help" -- $argv
    if set -q _flag_help
	    set -l normal (set_color normal)
	    set -l green (set_color green)
	    echo
	    echo "Manage global site packages."
	    echo
	    echo "Usage: "$green"vf globalpackages [<action>] [--quiet/-q]"$normal
	    echo
	    echo "Available actions: "$green"enable"$normal", "$green"disable"$normal", "$green"toggle"$normal" (default)"
	    return 0
    end

    if set -q VIRTUAL_ENV
	    set -l action $argv[1]
	    set -l action_args

	    if begin; test (count $argv) -eq 0; or string match -qr '^\-' -- $argv[1]; end
	        # no action passed, default to toggle
	        set action "toggle"
	        set action_args $argv[1..-1]
	    else
	        set action_args $argv[2..-1]
	    end

	    set -l funcname "__vfsupport_globalpackages_$action"

	    if functions -q $funcname
	        eval $funcname $action_args
	    else
	        echo "Invalid action: $action."
	        return 1
	    end
    else
	    echo "No active virtual environment."
	    return 1
    end
end

function __vfsupport_globalpackages_enable --description "Enable global site packages"
    argparse -n "vf globalpackages enable" "q/quiet" -- $argv
    pushd $VIRTUAL_ENV
    if test -e $VIRTUALFISH_VENV_CONFIG_FILE  # PEP 405
	    command sed -i '/include-system-site-packages/ s/\(true\|false\)/true/' $VIRTUALFISH_VENV_CONFIG_FILE
    else  # legacy
	    # use site-packages/.. to avoid ending up in python-wheels
	    pushd $VIRTUAL_ENV/lib/python*/site-packages/..
	    touch $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
	    popd
    end
    popd

    if not set -q _flag_quiet
	    echo "Global site packages enabled."
    end
end

function __vfsupport_globalpackages_disable --description "Disable global site packages"
    argparse -n "vf globalpackages disable" "q/quiet" -- $argv
    pushd $VIRTUAL_ENV
    if test -e $VIRTUALFISH_VENV_CONFIG_FILE  # PEP 405
	    command sed -i '/include-system-site-packages/ s/\(true\|false\)/false/' $VIRTUALFISH_VENV_CONFIG_FILE
    else  # legacy
	    # use site-packages/.. to avoid ending up in python-wheels
	    pushd $VIRTUAL_ENV/lib/python*/site-packages/..
	    command rm -f $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
	    popd
    end
    popd

    if not set -q _flag_quiet
	    echo "Global site packages disabled."
    end
end

function __vfsupport_globalpackages_toggle --description "Toggle global site packages"
    pushd $VIRTUAL_ENV
    set -l globalpkgs_enabled
    if test -e $VIRTUALFISH_VENV_CONFIG_FILE  # PEP 405
	    if [ "true" = (command sed -n 's/include-system-site-packages\s=\s\(true\|false\)/\1/p' $VIRTUALFISH_VENV_CONFIG_FILE) ]
	        set globalpkgs_enabled 0
	    else
	        set globalpkgs_enabled 1
	    end
    else  # legacy
	    # use site-packages/.. to avoid ending up in python-wheels
	    pushd $VIRTUAL_ENV/lib/python*/site-packages/..
	    if test -e $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
	        set globalpkgs_enabled 0
	    else
	        set globalpkgs_enabled 1
	    end
	    popd
    end
    popd

    if test $globalpkgs_enabled -eq 0
	    __vfsupport_globalpackages_disable $argv
    else
	    __vfsupport_globalpackages_enable $argv
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
    complete -x -c vf -n '__vfcompletion_using_command connect' -a "(vf ls)"
    complete -x -c vf -n '__vfcompletion_using_command rm' -a "(vf ls)"
    complete -x -c vf -n '__vfcompletion_using_command upgrade' -a "(vf ls)"
end

function __vfsupport_get_default_python --description "Return Python interpreter defined in variables, if any"
    argparse "e/exec" -- $argv
    # Prefer VIRTUALFISH_DEFAULT_PYTHON unless --exec is passed
    if begin; not set -q _flag_exec; and set -q VIRTUALFISH_DEFAULT_PYTHON; end
        echo $VIRTUALFISH_DEFAULT_PYTHON
    else if set -q VIRTUALFISH_PYTHON_EXEC
        echo $VIRTUALFISH_PYTHON_EXEC
    else if set -q VIRTUALFISH_DEFAULT_PYTHON
        echo $VIRTUALFISH_DEFAULT_PYTHON
    else
        echo python
    end
end

function __vfsupport_compare_py_versions --description "Return status code 1 if specified Python version is less than another"
    set -l version_to_compare (string split . $argv[1])
    set -l reference_version (string split . $argv[2])
    if test $version_to_compare[1] -lt $reference_version[1]
        return 1
    else if test $version_to_compare[2] -lt $reference_version[2]
        return 1
    else if test $version_to_compare[2] -gt $reference_version[2]
        return 0
    else if test $version_to_compare[3] -lt $reference_version[3]
        return 1
    end
    return 0
end

function __vf_install --description "Install VirtualFish"
    echo "VirtualFish is already installed! Hooray! To install extra plugins, use the addplugins command."
    return 0
end

function __vf_uninstall --description "Uninstall VirtualFish"
    set -l python (__vfsupport_get_default_python --exec)
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
    set -l python (__vfsupport_get_default_python --exec)
    $python -m virtualfish.loader.installer addplugins $argv
end

function __vf_rmplugins --description "Remove one or more plugins"
    if test (count $argv) -lt 1
        echo "Provide a plugin to remove"
        return -1
    end
    set -l python (__vfsupport_get_default_python --exec)
    $python -m virtualfish.loader.installer rmplugins $argv
end

function __vfsupport_check_python --description "Ensure Python/Pip are in a working state"
    argparse "p/pip" -- $argv
    set -l python_path $argv[1]
    set -l pipflag ""
    if set -q _flag_pip
        set pipflag "-m pip"
    end
    set -l test_py (fish -c "'$python_path' $pipflag -V" 2>/dev/null)
    if test $status -ne 0
        return 1
    else
        return 0
    end
end
