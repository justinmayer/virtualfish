################
# Automatic activation

if not set -q VIRTUALFISH_ACTIVATION_FILE
    set -g VIRTUALFISH_ACTIVATION_FILE .venv
end

function __vfsupport_auto_activate --on-variable PWD
    if status --is-command-substitution
        return
    end

    # find an auto-activation file
    set -l activation_root $PWD
    set -l new_virtualenv_name ""
    while test $activation_root != ""
        if test -f "$activation_root/$VIRTUALFISH_ACTIVATION_FILE"
            set new_virtualenv_name (cat "$activation_root/$VIRTUALFISH_ACTIVATION_FILE")
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

#automatically activate if started in a directory with a virtualenv in it
__vfsupport_auto_activate
