# Set up the configurable filename
if not set -q VIRTUALFISH_ENVIRONMENT_FILE
    set -g VIRTUALFISH_ENVIRONMENT_FILE .env
end

function __vfsupport_set_env_file_path --description "Set VIRTUALFISH_ENVIRONMENT_FILE_PATH to appropriate value"
    set -l vf_base (basename $VIRTUAL_ENV)
    set -l vf_path $VIRTUAL_ENV/$VIRTUALFISH_ENVIRONMENT_FILE
    # Check if projects plugin is used
    if set -q PROJECT_HOME
        set -l project_path $PROJECT_HOME/$vf_base/$VIRTUALFISH_ENVIRONMENT_FILE
        if not test -r $project_path
            and test -r $vf_path
            set -g VIRTUALFISH_ENVIRONMENT_FILE_PATH $vf_path
        else
            set -g VIRTUALFISH_ENVIRONMENT_FILE_PATH $project_path
        end
    else
        set -g VIRTUALFISH_ENVIRONMENT_FILE_PATH $vf_path
    end
end

function __vfext_environment_activate --on-event virtualenv_did_activate
    __vfsupport_set_env_file_path

    if test -r $VIRTUALFISH_ENVIRONMENT_FILE_PATH
        while read -l line
            # Skip empty lines and comments
            if not string length -q $line
                or test (string sub -s 1 -l 1 $line) = "#"
                continue
            end

            set key (echo $line | cut -d = -f 1)
            set value (echo $line | cut -d = -f 2-)

            # Preserve existing env var with shared name
            if set -q $key
                set -gx __VF_ENVIRONMENT_OLD_VALUE_$key $$key
            end

            # Eval to allow for expanding variables, e.g. PATH=$PATH foo
            set -gx $key (eval echo $value)
        end < $VIRTUALFISH_ENVIRONMENT_FILE_PATH
    end
end

function __vfext_environment_deactivate --on-event virtualenv_will_deactivate
    __vfsupport_set_env_file_path

    if test -r $VIRTUALFISH_ENVIRONMENT_FILE_PATH
        while read -l line
            # Skip empty lines and comments
            if not string length -q $line
                or test (string sub -s 1 -l 1 $line) = "#"
                continue
            end

            set key (echo $line | cut -d = -f 1)
            set old_key __VF_ENVIRONMENT_OLD_VALUE_$key

            # Check if old value was preserved
            if set -q $old_key
                set -gx $key $$old_key
                set -e $old_key
            else
                set -e $key
            end
        end < $VIRTUALFISH_ENVIRONMENT_FILE_PATH
    end
end

function __vf_environment --description "Edit the environment variables for the active virtual environment"
    if set -q VIRTUAL_ENV
        __vfsupport_set_env_file_path
        # Deactivate before applying new env vars to avoid stomping stashed values
        __vfext_environment_deactivate
        eval $EDITOR $VIRTUALFISH_ENVIRONMENT_FILE_PATH
        __vfext_environment_activate
    else
        echo "Must have a virtual env active to run command"
    end
end
