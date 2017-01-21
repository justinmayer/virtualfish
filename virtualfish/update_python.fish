function __vf_update_python --description "change the python interpreter of the current project"
    if [ (count $argv) -lt 1 ]
        if set -q VIRTUALFISH_DEFAULT_PYTHON
            set python $VIRTUALFISH_DEFAULT_PYTHON
        else
            set python python
        end
    else
        set python $argv[1]
    end
    if not which $python ^ /dev/null
        echo "You must set a valid python interpreter"
        return 1
    end
    if not set -q VIRTUAL_ENV
        echo "You must run this command with a virtual_env activated"
        return 1
    end

    set name (basename $VIRTUAL_ENV)
    set packages (pip freeze)

    echo Changing the interpreter of the virtualenv $name to $python

    vf deactivate
    and vf rm $name
    and vf new -p $python $name
    and pip install -U $packages
end

function __vf_fix_python --description "fix the python interpreter of the current project"
    python --version
    or vf update_python $argv[1]
end
