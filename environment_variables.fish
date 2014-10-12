if not set -q VIRTUALFISH_ENVIRONMENT_VARIABLES_FILE
    set -g VIRTUALFISH_ENVIRONMENT_VARIABLES_FILE .venvvars
end
if not set -q VIRTUALFISH_ENVIRONMENT_VARIABLES_PREFIX
    set -g VIRTUALFISH_ENVIRONMENT_VARIABLES_PREFIX _VF_OLD_
end

function __vf_set_environment_variables --on-event virtualenv_did_activate

    set -l project_venvvar_file $PROJECT_HOME/(basename $VIRTUAL_ENV)/$VIRTUALFISH_ENVIRONMENT_VARIABLES_FILE
    set -l venv_venvvar_file $VIRTUAL_ENV/$VIRTUALFISH_ENVIRONMENT_VARIABLES_FILE

    # Prefer project based environment config over virtualenv environment config
    if [ -f "$project_venvvar_file" ]
        set venvvar_file $project_venvvar_file
    else if [ -f "$venv_venvvar_file" ]
        set venvvar_file $venv_venvvar_file
    end

    if [ -f "$venvvar_file" ]
        cat $venvvar_file | while read -l key value
            # Save all currently existing env vars to their prefixed counter part
            if set -q $key
                set -gx $VIRTUALFISH_ENVIRONMENT_VARIABLES_PREFIX$key $$key
            end
            # Set new variable
            set -gx $key $value
        end
    end

end

function __vf_unset_environment_variables --on-event virtualenv_did_deactivate

    set -l project_venvvar_file $PROJECT_HOME/(basename $VIRTUAL_ENV)/$VIRTUALFISH_ENVIRONMENT_VARIABLES_FILE
    set -l venv_venvvar_file $VIRTUAL_ENV/$VIRTUALFISH_ENVIRONMENT_VARIABLES_FILE

    # Prefer project based environment config over virtualenv environment config
    if [ -f "$project_venvvar_file" ]
        set venvvar_file $project_venvvar_file
    else if [ -f  "$venv_venvvar_file" ]
        set venvvar_file $venv_venvvar_file
    end

    if [ -f "$venvvar_file" ]
        cat $venvvar_file | while read key value
            # Restore existing env vars
            set -l old_key $VIRTUALFISH_ENVIRONMENT_VARIABLES_PREFIX$key
            if set -q $old_key
                set -gx $key $$old_key
                set -e $VIRTUALFISH_ENVIRONMENT_VARIABLES_PREFIX$key
            else
                set -e $key
            end
        end
    end
end

