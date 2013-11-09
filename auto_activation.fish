################
# Automatic activation

if not set -q VIRTUALFISH_ACTIVATION_FILE
    set -g VIRTUALFISH_ACTIVATION_FILE .venv
end

function __vfsupport_auto_activate --on-variable PWD
    if status --is-command-substitution # doesn't work with 'or', inexplicably
        return
    end

    # find an auto-activation file
    set -l vfeloc $PWD
    while test ! "$vfeloc" = "" -a ! -f "$vfeloc/$VIRTUALFISH_ACTIVATION_FILE"
        # this strips the last path component from the path.
        set vfeloc (echo "$vfeloc" | sed 's|/[^/]*$||')
    end

    set -l newve
    if [ -f "$vfeloc/$VIRTUALFISH_ACTIVATION_FILE" ]
        set newve (cat "$vfeloc/$VIRTUALFISH_ACTIVATION_FILE")
    end

    # apply new venv if changed
    set -l currentve
    if set -q VIRTUAL_ENV
        set currentve (basename "$VIRTUAL_ENV")
    end

    if [ "$newve" != "" -a "$newve" != "$currentve" ]
        vf activate $newve
        set -g VF_AUTO_ACTIVATED yes
    end

    # deactivate venv if it was autoactivated before and we've moved out of it
    if [ "$newve" = "" -a "$VF_AUTO_ACTIVATED" = "yes" ]
        vf deactivate
    end
end

#automatically activate if started in a directory with a virtualenv in it
__vfsupport_auto_activate
