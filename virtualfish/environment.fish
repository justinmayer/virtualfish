function __vfext_environment_activate --on-event virtualenv_did_activate
    if test -f $VIRTUAL_ENV/virtualfish-environment
        for line in (cat $VIRTUAL_ENV/virtualfish-environment)
            set key (echo $line | cut -d = -f 1)
            set value (echo $line | cut -d = -f 2-)

            # Preserve existing env var with shared name
            if set -q $key
                set -xg __VF_ENVIRONMENT_OLD_VALUE_$key $$key
            end

            # Eval to allow for expanding variables, e.g. PATH=$PATH foo
            set -gx $key (eval echo $value)
        end
    end
end

function __vfext_environment_deactivate --on-event virtualenv_will_deactivate
    if test -f $VIRTUAL_ENV/virtualfish-environment
        for line in (cat $VIRTUAL_ENV/virtualfish-environment)
            set key (echo $line | cut -d = -f 1)
            set old_key __VF_ENVIRONMENT_OLD_VALUE_$key

            # Check if old value was preserved
            if set -q $old_key
                set -xg $key $$old_key
                set -e $old_key
            else
                set -e $key
            end
        end
    end
end

function __vf_environment --description "Edit the environment variables for the active virtual environment"
    if set -q 'VIRTUAL_ENV'
        eval $EDITOR $VIRTUAL_ENV/virtualfish-environment
        # Deactivate before applying new env vars to avoid stomping stashed values
        __vfext_environment_deactivate
        __vfext_environment_activate
    else
        echo "Must have a virtual env active to run command"
    end
end
