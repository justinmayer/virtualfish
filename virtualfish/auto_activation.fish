################
# Automatic activation

function __vfsupport_auto_activate --on-variable PWD
    if status --is-command-substitution
        return
    end

    # find an auto-activation file or determine whether inside a project directory
    set -l activation_root $PWD
    set -l new_virtualenv_name ""

    # Projects plugin compatibility: Enable auto-deactivation (1/3)
    # Check if active virtualenv (if any) is connected to a project
    if test -e "$VIRTUAL_ENV/.project"
        set project_path (command cat "$VIRTUAL_ENV/.project")
    end

    while test $activation_root != ""
        if test -f "$activation_root/$VIRTUALFISH_ACTIVATION_FILE"
            set new_virtualenv_name (command cat "$activation_root/$VIRTUALFISH_ACTIVATION_FILE")
            break

        # Projects plugin compatibility: Enable auto-deactivation (2/3)
        # vf workon might activate virtualenvs without activation files. To detect those instances
        # here in the Auto-activation plugin, check if activation root is a project path. If so,
        # set new_virtualenv_name to the basename of the project path
        else if test "$project_path" = "$activation_root"
            set new_virtualenv_name (command basename $project_path)
            break
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

        # Projects plugin compatibility: Enable auto-deactivation (3/3)
        # vf workon doesn't set VF_AUTO_ACTIVATED. To deactivate virtualenv automatically when
        # leaving project directory, we check if any virtualenv is active while not in project path
        else if begin set -q VIRTUAL_ENV; and test "$project_path" != "$activation_root"; end
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
