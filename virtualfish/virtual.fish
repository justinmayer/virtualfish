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
        if contains $PATH[$i] $_VF_EXTRA_PATH
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

function __vf_new --description "Create a new virtualenv"

    # Deactivate the current virtualenv, if one is active
    if set -q VIRTUAL_ENV
        vf deactivate
    end

    emit virtualenv_will_create
    set envname $argv[-1]
    set -e argv[-1]
    if set -q VIRTUALFISH_DEFAULT_PYTHON
        set argv "--python" $VIRTUALFISH_DEFAULT_PYTHON $argv
    end
    set -lx PIP_USER 0
    eval $VIRTUALFISH_PYTHON_EXEC -m virtualenv $argv $VIRTUALFISH_HOME/$envname
    set vestatus $status
    if begin; [ $vestatus -eq 0 ]; and [ -d $VIRTUALFISH_HOME/$envname ]; end
        vf activate $envname
        emit virtualenv_did_create
        emit virtualenv_did_create:(basename $VIRTUAL_ENV)
    else
        echo "Error: The virtualenv wasn't created properly."
        echo "virtualenv returned status $vestatus."
        if test (count $argv) -ge 1
            echo "Make sure you put any option flags before the virtualenv name."
            echo "Good example: "(set_color green)"vf new -p python3.5 myproject" (set_color normal)
            echo "Bad example:  "(set_color red)"vf new myproject -p python3.5" (set_color normal)
        end
        return 1
    end
end

function __vf_rm --description "Delete a virtualenv"
    if not [ (count $argv) -eq 1 ]
        echo "You need to specify exactly one virtualenv."
        return 1
    end
    if begin; set -q VIRTUAL_ENV; and [ $argv[1] = (basename $VIRTUAL_ENV) ]; end
        echo "You can't delete a virtualenv you're currently using."
        return 1
    end
    echo "Removing $VIRTUALFISH_HOME/$argv[1]"
    rm -rf $VIRTUALFISH_HOME/$argv[1]
end

function __vf_ls --description "List all of the available virtualenvs"
    pushd $VIRTUALFISH_HOME
    for i in */bin/python
        echo $i
    end | sed "s|/bin/python||"
    popd
end

function __vf_cd --description "Change directory to this virtualenv"
    if set -q VIRTUAL_ENV
        cd $VIRTUAL_ENV
    else
        echo "Cannot locate an active virtualenv."
    end
end

function __vf_cdpackages --description "Change to the site-packages directory of this virtualenv"
    vf cd
    cd (find . -name site-packages -type d | head -n1)
end

function __vf_tmp --description "Create a virtualenv that will be removed when deactivated"
    set -l env_name (printf "%s%.4x" "tempenv-" (random) (random) (random))
    vf new $argv $env_name
    set -g VF_TEMPORARY_ENV
end

function __vfsupport_remove_env_on_deactivate_or_exit --on-event virtualenv_did_deactivate --on-process %self
    if set -q VF_TEMPORARY_ENV
        echo "Removing temporary virtualenv" (basename $VIRTUAL_ENV)
        rm -rf $VIRTUAL_ENV
        set -e VF_TEMPORARY_ENV
    end
end

function __vf_addpath --description "Adds a path to sys.path in this virtualenv"
    if set -q VIRTUAL_ENV
        set -l site_packages (eval "$VIRTUAL_ENV/bin/python -c 'import distutils; print(distutils.sysconfig.get_python_lib())'")
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
            rm -f "$path_file.tmp"
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


function __vf_connect --description "Connect this virtualenv to the current directory"
    if set -q VIRTUAL_ENV
        basename $VIRTUAL_ENV > $VIRTUALFISH_ACTIVATION_FILE
    else
        echo "No virtualenv is active."
    end
end

function __vf_help --description "Print VirtualFish usage information"
    echo "virtualfish $VIRTUALFISH_VERSION"
    echo
    echo "Usage: vf <command> [<args>]"
    echo
    echo "Available commands:"
    echo
    for sc in (functions -a | sed -n '/__vf_/{s///g;p;}')
        set -l helptext (functions "__vf_$sc" | head -n 1 | sed -E "s|.*'(.*)'.*|\1|")
        printf "    %-15s %s\n" $sc (set_color 555)$helptext(set_color normal)
    end
    echo
    echo "For full documentation, see: http://virtualfish.readthedocs.org/en/$VIRTUALFISH_VERSION/"
end

function __vf_globalpackages --description "Toggle global site packages"
  if set -q VIRTUAL_ENV
      vf cd
      # use site-packages/.. to avoid ending up in python-wheels
      cd lib/python*/site-packages/..
      if test -e $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
        echo "Enabling global site packages"
        rm $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
      else
        echo "Disabling global site packages"
        touch $VIRTUALFISH_GLOBAL_SITE_PACKAGES_FILE
      end
    else
        echo "No virtualenv is active."
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
        set -l helptext (functions "__vf_$sc" | head -n 1 | sed -E "s|.*'(.*)'.*|\1|")
        complete -x -c vf -n '__vfcompletion_needs_command' -a $sc -d $helptext
    end

    complete -x -c vf -n '__vfcompletion_using_command activate' -a "(vf ls)"
    complete -x -c vf -n '__vfcompletion_using_command rm' -a "(vf ls)"
end
