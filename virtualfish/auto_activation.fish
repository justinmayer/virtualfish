################
# Automatic activation

function __vfsupport_auto_activate --on-variable PWD
    if status --is-command-substitution
        return
    end

    # find an auto-activation file or determine whether inside a project directory
    set -l activation_root $PWD
    set -l new_virtualenv_name ""
    while test $activation_root != ""
        if test -f "$activation_root/$VIRTUALFISH_ACTIVATION_FILE"
            set new_virtualenv_name (command cat "$activation_root/$VIRTUALFISH_ACTIVATION_FILE")
            break
        # If the projects plugin is used alongside auto activation, switching into project directories
        # using `vf workon` causes auto activation even if no activation file is present. In this case,
        # we make sure the virtualenv is not deactivated when changing into project subdirectories by
        # setting new_virtualenv_name to the basename of activation_root if project_path = activation_root
        else if type -q __vf_workon
            if test -e "$VIRTUAL_ENV/.project"
                set -l project_path (command cat "$VIRTUAL_ENV/.project")
                if test $project_path = $activation_root
                    set new_virtualenv_name (command basename $activation_root)
                    break
                end
            end
        end
        # this strips the last path component from the path.
        set activation_root (echo $activation_root | sed 's|/[^/]*$||')
    end


    if test $new_virtualenv_name != ""
        # if the virtualenv in the file is different, switch to it
        if begin; not set -q VIRTUAL_ENV; or test $new_virtualenv_name != (basename $VIRTUAL_ENV); end
            vf activate $new_virtualenv_name
            set -g VF_AUTO_ACTIVATED $activation_root
        end
    else
        # if there's an auto-activated virtualenv, deactivate it
        if set -q VIRTUAL_ENV VF_AUTO_ACTIVATED
            vf deactivate
        end
    end
end

# remove the auto-activation flag on deactivation
function __vfsupport_deactivate_remove_flag --on-event virtualenv_did_deactivate
    # remove autoactivated flag
    if set -q VF_AUTO_ACTIVATED
        set -e VF_AUTO_ACTIVATED
    end
end

# if `vf connect` is run, de-activate when leaving $PWD
function __vfsupport_auto_deactivate_after_connect --on-event virtualenv_did_connect
    set -q VF_AUTO_ACTIVATED; or set -g VF_AUTO_ACTIVATED $PWD
end

#automatically activate if started in a directory with a virtualenv in it
__vfsupport_auto_activate
