# VirtualFish
# A Virtualenv wrapper for the Fish Shell based on Doug Hellman's virtualenvwrapper

if not set -q VIRTUALFISH_HOME
	set -g VIRTUALFISH_HOME $HOME/.virtualenvs
end

if not set -q VIRTUALFISH_ACTIVATION_FILE
	set -g VIRTUALFISH_ACTIVATION_FILE .venv
end

if set -q VIRTUALFISH_COMPAT_ALIASES
        function workon
                vf activate $argv[1]
        end
        function deactivate
                vf deactivate
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
	
	# remove autoactivated flag
	if set -q VF_AUTO_ACTIVATED
		set -e VF_AUTO_ACTIVATED
	end

	emit virtualenv_did_deactivate
	emit virtualenv_did_deactivate:(basename $VIRTUAL_ENV)

	set -e VIRTUAL_ENV
end

function __vf_new --description "Create a new virtualenv"
	set envname $argv[-1]
	set -e argv[-1]
	virtualenv $argv $VIRTUALFISH_HOME/$envname
	set vestatus $status
	if [ $vestatus -eq 0 ]; and [ -d $VIRTUALFISH_HOME/$envname ]
		vf activate $envname
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
	if set -q VIRTUAL_ENV; and [ $argv[1] = $VIRTUAL_ENV ]
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

function __vf_connect --description "Connect this virtualenv to the current directory"
	if set -q VIRTUAL_ENV
		basename $VIRTUAL_ENV > $VIRTUALFISH_ACTIVATION_FILE
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
end

################
# Automatic activation
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
