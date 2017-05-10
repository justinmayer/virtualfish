# Set up the configurable filename
if not set -q VIRTUALFISH_ENVIRONMENT_FILE
    set -g VIRTUALFISH_ENVIRONMENT_FILE .env
end

function __vfsupport_set_env_file_path --description "Set VIRTUALFISH_ENVIRONMENT_FILE_PATH to appropriate value"
    set -l vf_path $VIRTUAL_ENV/$VIRTUALFISH_ENVIRONMENT_FILE
    # Check if Projects plugin is used
    if not set -q PROJECT_HOME
        # Always look in the virtualenv dir when not using Projects plugin
        echo $vf_path
    else
        set -l project_path $PROJECT_HOME/(basename $VIRTUAL_ENV)/$VIRTUALFISH_ENVIRONMENT_FILE
        if not test -r $project_path
            and test -r $vf_path
            # Only use virtualenv dir when there is already a file there
            echo $vf_path
        else
            # Prefer to use the project dir
            echo $project_path
        end
    end
end

function __vfext_environment_activate --on-event virtualenv_did_activate
    set -l env_file_path (__vfsupport_set_env_file_path)

    if test -r $env_file_path
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
        end < $env_file_path
    end
end

function __vfext_environment_deactivate --on-event virtualenv_will_deactivate
    set -l env_file_path (__vfsupport_set_env_file_path)

    if test -r $env_file_path
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
        end < $env_file_path
    end
end

function __vf_environment --description "Edit the environment variables for the active virtual environment"
    # Requires active virtualenv
    if not set -q VIRTUAL_ENV
        echo "Must have a virtual env active to run command"
        return 1
    end

    # Check if $VISUAL or $EDITOR is set, otherwise use vi (Git default)
    if set -q VISUAL
        set editor $VISUAL
    else if set -q EDITOR
        set editor $EDITOR
    else
        set editor vi
    end

    set -l env_file_path (__vfsupport_set_env_file_path)
    # Deactivate before applying new env vars to avoid stomping stashed values
    __vfext_environment_deactivate
    eval $editor $env_file_path
    __vfext_environment_activate
end
