function workon
    if not set -q argv[1]
        vf ls
    else
        vf activate $argv[1]
    end
end
function deactivate
    vf deactivate
end
function mktmpenv
    vf tmp $argv
end
function mkvirtualenv
    # Check if the first argument is an option to virtualenv
    # if it is then the the last argument must be the DEST_DIR.
    set -l idx 1
    switch $argv[1]
        case '-*'
            set idx -1
    end

    # Extract the DEST_DIR and remove it from $argv
    set -l env_name $argv[$idx]
    set -e argv[$idx]

    vf new $argv $env_name
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
