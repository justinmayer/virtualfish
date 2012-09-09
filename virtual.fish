# VirtualFish
# A Virtualenv wrapper for the Fish Shell based on Doug Hellman's virtualenvwrapper

if not set -q VIRTUALFISH_HOME
	set -g VIRTUALFISH_HOME $HOME/.virtualenvs
end

if set -q VIRTUALFISH_COMPAT_ALIASES
	alias workon acvirtualenv
	alias deactivate devirtualenv
end

function acvirtualenv --description "Activate a virtualenv"
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
		devirtualenv
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

function devirtualenv --description "Deactivate the currently-activated virtualenv"

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
	
	# remove autoactivated flag
	if set -q VF_AUTO_ACTIVATED
		set -e VF_AUTO_ACTIVATED
	end

	emit virtualenv_did_deactivate
	emit virtualenv_did_deactivate:(basename $VIRTUAL_ENV)

	set -e VIRTUAL_ENV
end

function mkvirtualenv --description "Create a new virtualenv"
	set envname $argv[-1]
	set -e argv[-1]
	virtualenv $argv $VIRTUALFISH_HOME/$envname
	set vestatus $status
	if [ $vestatus -eq 0 ]; and [ -d $VIRTUALFISH_HOME/$envname ]
		acvirtualenv $envname
	else
		echo "Error: The virtualenv wasn't created properly."
		echo "virtualenv returned status $vestatus."
		return 1
	end
end

function rmvirtualenv --description "Delete a virtualenv"
	if not [ (count $argv) -eq 1 ]
		echo "You need to specify exactly one virtualenv."
		return 1
	end
	if set -q VIRTUAL_ENV; and [ $argv[1] = $VIRTUAL_ENV ]
		echo "You can't delete a virtualenv you're currently using."
		return 1
	end
	echo "Removing $VIRTUALFISH_HOME/$argv[1]"
	rm -rf $VIRTUALFISH_HOME/$argv[1]
end

function lsvirtualenv --description "List all of the available virtualenvs"
	pushd $VIRTUALFISH_HOME
	for i in */bin/python
		echo $i
	end | sed "s|/bin/python||"
	popd
end

function cdvirtualenv --description "Change directory to currently-activated virtualenv"
    if set -q VIRTUAL_ENV
        cd $VIRTUAL_ENV
    else
        echo "Cannot locate an active virtualenv."
    end 
end

# Autocomplete
complete -x -c acvirtualenv -a "(lsvirtualenv)"
complete -x -c rmvirtualenv -a "(lsvirtualenv)"

# Automatic activation
function __vf_auto_activate --on-variable PWD
	if [ "$_VF_AUTOACTIVATE_RECURSION_GUARD" = "on" ]
		return
	end
	if status --is-command-substitution # doesn't work with 'or', inexplicably
		return
	end
		
	set -g _VF_AUTOACTIVATE_RECURSION_GUARD on #avoid infinite recursion
	
	set -l newwd $PWD
						
	# find a .vfenv file
	while [ ! \("$PWD" = "$HOME"\) -a ! "$PWD" = "/" -a ! -f .vfenv ]
		cd ..
	end	
	set -l newve			
	if [ -f .vfenv ]
		set newve (cat .vfenv)
	end				
	cd $newwd
	set -e newwd
	
	# apply new venv if changed
	set currentve (basename "$VIRTUAL_ENV")
	if [ "$newve" != "" -a "$newve" != "$currentve" ]
		acvirtualenv $newve
		set -g VF_AUTO_ACTIVATED yes
	end
	
	# deactivate venv if it was autoactivated before and we've moved out of it
	if [ "$newve" = "" -a "$VF_AUTO_ACTIVATED" = "yes" ]
		devirtualenv
	end
	
	set -g _VF_AUTOACTIVATE_RECURSION_GUARD off					
	set -e __VF_AUTOACTIVATE_RECURSION_GUARD # doesn't work, not sure why
end

#automatically activate if started in a directory with a virtualenv in it
__vf_auto_activate
