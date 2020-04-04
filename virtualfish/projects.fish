if not set -q PROJECT_HOME
    set -g PROJECT_HOME $HOME/projects
end

if not set -q VIRTUALFISH_ACTIVATION_FILE
    set -g VIRTUALFISH_ACTIVATION_FILE .venv
end

function __vf_workon --description "Work on a project"
    if [ (count $argv) -lt 1 ]
        echo "You must specify a project or virtual environment."
        return 1
    end
    # Matches a virtualenv name and possibly a project name
    if [ -d $VIRTUALFISH_HOME/$argv[1] ]
        vf activate $argv[1]
        if [ -e $VIRTUAL_ENV/.project ]
            set -l project_file_path (command cat $VIRTUAL_ENV/.project)
            if [ -d $project_file_path ]
                cd $project_file_path
            else
                echo ".project file path does not exist: $project_file_path"
                return 2
            end
        else if [ -d $PROJECT_HOME/$argv[1] ]
            cd $PROJECT_HOME/$argv[1]
        end
    # Matches a project name but not a virtualenv name
    else if [ -d $PROJECT_HOME/$argv[1] ]
        set -l project_name $argv[1]
        set -l venv_file "$PROJECT_HOME/$project_name/$VIRTUALFISH_ACTIVATION_FILE"
        if [ -f $venv_file ]
            vf activate (command cat $venv_file)
        else
            echo "No virtual environment found."
        end
        cd $PROJECT_HOME/$argv[1]
    else
        echo "No project or virtual environment named $argv[1] exists."
        return 2
    end
end

function __vf_project --description "Create a new project and virtualenv with the name provided"
    set -l project_name
    set -l virtualenv_args
    argparse --ignore-unknown "h/help" "p/python=" -- $argv
    if set -q _flag_help
        set -l normal (set_color normal)
        set -l green (set_color green)
        echo "Purpose: Creates a new project and virtualenv with the name provided"
        echo "Usage: "$green"vf project "(set_color -di)"[-p <python-version>] [<virtualenv-options>]"$normal$green" <project/virtualenv-name>"$normal
        echo
        echo "Examples:"
        echo
        echo $green"vf project -p /usr/local/bin/python3 yourproject"$normal
        echo $green"vf project -p python3.8 --system-site-packages yourproject"$normal
        echo
        echo "To see available "(set_color blue)"Virtualenv"$normal" option flags, run: "$green"virtualenv --help"$normal
        return 0
    end
    if set -q _flag_python
        set virtualenv_args "--python" $_flag_python
    end
    # Unpack remaining args: Virtualenv flags and the project/environment name
    for arg in $argv
        switch $arg
            case "-*"
                set virtualenv_args $virtualenv_args $arg
            case "*"
                set project_name $arg
        end
    end
    if [ (count $project_name) -lt 1 ]
        echo "You must specify a name for the new project & virtual environment."
        return 1
    end
    set -l project_path "$PROJECT_HOME/$project_name"
    if [ -d $project_path ]
        echo "A project with that name already exists at: $project_path"
        return 2
    else
        vf new $project_name $virtualenv_args
        mkdir -p $project_path
        cd $project_path
    end
end

function __vf_lsprojects --description "List projects"
    if [ ! -d $PROJECT_HOME ]
        return 2
    end

    pushd $PROJECT_HOME
    for i in *
        if [ -d $i ]
            echo $i
        end
    end
    popd
end

function __vf_cdproject --description "Change working directory to project directory"
    if set -q VIRTUAL_ENV
        if [ -e $VIRTUAL_ENV/.project ]
            set -l project_file_path (command cat $VIRTUAL_ENV/.project)
            if [ -d $project_file_path ]
                cd $project_file_path
            else
                echo ".project file path does not exist: $project_file_path"
                return 2
            end
        else if [ -n "$PROJECT_HOME" ]
            set -l project_name (basename $VIRTUAL_ENV)
            if [ -d $PROJECT_HOME/$project_name ]
                cd $PROJECT_HOME/$project_name
            end
        end
    end
end

function __vfsupport_enable_workon_project --on-event virtualfish_did_setup_plugins
    if type -q workon
        function mkproject
            vf project $argv
        end
        function cdproject
            vf cdproject
        end
        functions -e workon
        function workon
            if not set -q argv[1]
                set_color blue; echo "Projects:"; set_color normal
                vf lsprojects
                set_color blue; echo -e "\nVirtual environments:"; set_color normal
                vf ls
            else
                vf workon $argv[1]
            end
        end

        complete -x -c workon -a "(vf lsprojects)"
    end
end

complete -x -c vf -n '__vfcompletion_using_command workon' -a "(vf lsprojects)"
