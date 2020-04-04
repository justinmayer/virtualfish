function workon
    if not set -q argv[1]
        vf ls
    else
        vf activate $argv[1]
    end
end
function __vfsupport_define_deactivate_alias_upon_activation --on-event virtualenv_did_activate
    function deactivate
        vf deactivate
    end
end
function __vfsupport_undefine_deactivate_alias_upon_deactivation --on-event virtualenv_did_deactivate
    functions -e deactivate
end
function mktmpenv
    vf tmp $argv
end
function mkvirtualenv
    vf new $argv
end
function lsvirtualenv
    vf ls
end
function rmvirtualenv
    vf rm $argv
end
function add2virtualenv
    vf addpath $argv
end
function cdvirtualenv
    vf cd $argv
end
function cdsitepackages
    vf cdpackages $argv
end
function allvirtualenv
    vf all $argv
end
function setvirtualenvproject
    vf connect
end
function toggleglobalsitepackages
    vf globalpackages
end

complete -x -c workon -a "(vf ls)"
complete -x -c rmvirtualenv -a "(vf ls)"
