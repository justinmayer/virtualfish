# VirtualFish
# A Virtualenv wrapper for the Fish Shell based on Doug Hellman's virtualenvwrapper

if not set -q VIRTUALFISH_HOME
	set -g VIRTUALFISH_HOME $HOME/.virtualenvs
end

if set -q VIRTUALFISH_COMPAT_ALIASES
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
        function rmvirtualenv
                vf rm $argv
        end
        function add2virtualenv
        	__vf_addpath $argv
        end
        function cdvirtualenv
        	vf cd $argv
        end
        function cdsitepackages
        	vf cdpackages $argv
        end
end

function vf --description "VirtualFish: fish plugin to manage virtualenvs"
	# copy all but the first argument to $scargs
	set -l sc $argv[1]
	set -l funcname "__vf_$sc"
	set -l scargs

	if test (count $argv) -gt 1
		set scargs $argv[2..-1]
	end

	if functions -q $funcname
		eval $funcname $scargs
	else
		echo "The subcommand $sc is not defined"
	end
end

function __vf_activate --description "Activate a virtualenv"
	# check arguments
	if [ (count $argv) -lt 1 ]
		echo "You need to specify a virtualenv."
		return 1
	end
	if not [ -d $VIRTUALFISH_HOME/$argv[1] ]
		echo "The virtualenv $argv[1] does not exist."
		echo "You can create it with mkvirtualenv."
		return 2
	end

	#Check if a different env is being used
	if set -q VIRTUAL_ENV
		vf deactivate
	end

	emit virtualenv_will_activate
	emit virtualenv_will_activate:$argv[1]

	set -gx VIRTUAL_ENV $VIRTUALFISH_HOME/$argv[1]
	set -g _VF_EXTRA_PATH $VIRTUAL_ENV/bin
	set -gx PATH $_VF_EXTRA_PATH $PATH

	# hide PYTHONHOME
	if set -q PYTHONHOME
		set -g _VF_OLD_PYTHONHOME $PYTHONHOME
		set -e PYTHONHOME
	end

	emit virtualenv_did_activate
	emit virtualenv_did_activate:(basename $VIRTUAL_ENV)
end

function __vf_deactivate --description "Deactivate the currently-activated virtualenv"

	emit virtualenv_will_deactivate
	emit virtualenv_will_deactivate:(basename $VIRTUAL_ENV)

	# find elements to remove from PATH
	set to_remove
	for i in (seq (count $PATH))
		if contains $PATH[$i] $_VF_EXTRA_PATH
			set to_remove $to_remove $i
		end
	end

	# remove them
	for i in $to_remove
		set -e PATH[$i]
	end

	# restore PYTHONHOME
	if set -q _VF_OLD_PYTHONHOME
		set -gx PYTHONHOME $_VF_OLD_PYTHONHOME
		set -e _VF_OLD_PYTHONHOME
	end

	emit virtualenv_did_deactivate
	emit virtualenv_did_deactivate:(basename $VIRTUAL_ENV)

	set -e VIRTUAL_ENV
end

function __vf_new --description "Create a new virtualenv"
    emit virtualenv_will_create
	set envname $argv[-1]
	set -e argv[-1]
	virtualenv $argv $VIRTUALFISH_HOME/$envname
	set vestatus $status
	if begin; [ $vestatus -eq 0 ]; and [ -d $VIRTUALFISH_HOME/$envname ]; end
		vf activate $envname
        emit virtualenv_did_create
        emit virtualenv_did_create:(basename $VIRTUAL_ENV)
	else
		echo "Error: The virtualenv wasn't created properly."
		echo "virtualenv returned status $vestatus."
		return 1
	end
end

function __vf_rm --description "Delete a virtualenv"
	if not [ (count $argv) -eq 1 ]
		echo "You need to specify exactly one virtualenv."
		return 1
	end
	if begin; set -q VIRTUAL_ENV; and [ $argv[1] = (basename $VIRTUAL_ENV) ]; end
		echo "You can't delete a virtualenv you're currently using."
		return 1
	end
	echo "Removing $VIRTUALFISH_HOME/$argv[1]"
	rm -rf $VIRTUALFISH_HOME/$argv[1]
end

function __vf_ls --description "List all of the available virtualenvs"
	pushd $VIRTUALFISH_HOME
	for i in */bin/python
		echo $i
	end | sed "s|/bin/python||"
	popd
end

function __vf_cd --description "Change directory to currently-activated virtualenv"
    if set -q VIRTUAL_ENV
        cd $VIRTUAL_ENV
    else
        echo "Cannot locate an active virtualenv."
    end
end

function __vf_cdpackages --description "Change to the site-packages directory of the active virtualenv"
	vf cd
	cd lib/python*/site-packages
end


function __vf_connect --description "Connect this virtualenv to the current directory"
	if set -q VIRTUAL_ENV
		basename $VIRTUAL_ENV > $VIRTUALFISH_ACTIVATION_FILE
	else
		echo "No virtualenv is active."
	end
end

function __vf_tmp --description "Create a temporary virtualenv that will be removed when deactivated"
	set -l env_name (printf "%s%.4x" "tempenv-" (random) (random) (random))
    set -g VF_TEMPORARY_ENV

	# Use will_deactivate here so that $VIRTUAL_ENV is available.
	function __vf_tmp_remove --on-event virtualenv_will_deactivate:$env_name
		echo "Removing $VIRTUAL_ENV"
		rm -rf $VIRTUAL_ENV
        set -e VF_TEMPORARY_ENV
	end

    # Ensure that the virtualenv gets deleted even if we close the shell w/o
    # explicitly deactivating.
    function __vfsupport_remove_temp_env_on_exit --on-process %self
        if set -q VF_TEMPORARY_ENV
            vf deactivate # the deactivate handler will take care of removing it
        end
    end

	vf new $argv $env_name
end

function __vf_addpath --description "Adds a path to sys.path in this virtualenv"
	if set -q VIRTUAL_ENV
		set -l site_packages (eval "$VIRTUAL_ENV/bin/python -c 'import distutils; print(distutils.sysconfig.get_python_lib())'")
		set -l path_file $site_packages/_virtualenv_path_extensions.pth

		set -l remove 0
		if test $argv[1] = "-d"
			set remove 1
			set -e argv[1]
		end

		if not test -f $path_file
	        echo "import sys; sys.__plen = len(sys.path)" > $path_file
	        echo "import sys; new=sys.path[sys.__plen:]; del sys.path[sys.__plen:]; p=getattr(sys,'__egginsert',0); sys.path[p:p]=new; sys.__egginsert = p+len(new)" >> $path_file
		end

		for pydir in $argv
			set -l absolute_path (eval "$VIRTUAL_ENV/bin/python -c 'import os,sys; sys.stdout.write(os.path.abspath(\"$pydir\")+\"\n\")'")
			if not test $pydir = $absolute_path
				echo "Warning: Converting \"$pydir\" to \"$absolute_path\"" 1>&2
			end

			if test $remove -eq 1
				sed -i.tmp "\:^$absolute_path\$: d" "$path_file"
			else
	            sed -i.tmp '1 a\
'"$absolute_path"'
' "$path_file"
			end
	        rm -f "$path_file.tmp"
		end
		return 0
	else
		echo "No virtualenv is active."
	end
end

################
# Autocomplete
# Based on https://github.com/zmalltalker/fish-nuggets/blob/master/completions/git.fish
begin
	function __vfcompletion_needs_command
		set cmd (commandline -opc)
			if test (count $cmd) -eq 1 -a $cmd[1] = 'vf'
			return 0
		end
		return 1
	end

	function __vfcompletion_using_command
		set cmd (commandline -opc)
		if test (count $cmd) -gt 1
			if test $argv[1] = $cmd[2]
				return 0
			end
		end
		return 1
	end

	# add completion for subcommands
	for sc in (functions -a | sed -n '/__vf_/{s///g;p;}')
		set -l helptext (functions "__vf_$sc" | head -n 1 | sed -E "s|.*'(.*)'.*|\1|")
		complete -x -c vf -n '__vfcompletion_needs_command' -a $sc -d $helptext
	end

	complete -x -c vf -n '__vfcompletion_using_command activate' -a "(vf ls)"
	complete -x -c vf -n '__vfcompletion_using_command rm' -a "(vf ls)"
    if set -q VIRTUALFISH_COMPAT_ALIASES
        complete -x -c workon -a "(vf ls)"
        complete -x -c rmvirtualenv -a "(vf ls)"
    end
end

