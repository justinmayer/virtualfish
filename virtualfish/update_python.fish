function __vf_update_python --description "Change the Python interpreter for the current environment"
    set -l python
    if [ (count $argv) -lt 1 ]
        if set -q VIRTUALFISH_DEFAULT_PYTHON
            set python $VIRTUALFISH_DEFAULT_PYTHON
        else if set -q VIRTUALFISH_PYTHON_EXEC
            set python $VIRTUALFISH_PYTHON_EXEC
        else
            set python (command -s python)
        end
    else
        set python (__vfsupport_find_python $argv[1])
    end
    if not test -x "$python"
        echo "You must specify a valid Python interpreter."
        return 1
    end
    if not set -q VIRTUAL_ENV
        echo "You must run this command with a virtual environment activated."
        return 1
    end

    set -l envname (basename $VIRTUAL_ENV)
    set -l packages (pip freeze)

    echo "Changing the interpreter of the '$envname' environment to $python"

    vf deactivate
    and vf rm $envname
    and vf new -p $python $envname
    and test -n "$packages"
    and pip install -U $packages
end

function __vf_fix_python --description "Fix the Python interpreter for the current environment"
    python --version
    or vf update_python $argv[1]
end
