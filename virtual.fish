# VirtualFish
# A Virtualenv wrapper for the Fish Shell based on Doug Hellman's virtualenvwrapper

if not set -q VIRTUALENV_HOME
	set -g VIRTUALENV_HOME $HOME/.virtualenvs
end

function acvirtualenv --description "Activate a virtualenv"
	# check arguments
	if [ (count $argv) -lt 1 ]
		echo "You need to specify a virtualenv."
		return 1
	end
	if not [ -d $VIRTUALENV_HOME/$argv[1] ]
		echo "The virtualenv $argv[1] does not exist."
		echo "You can create it with mkvirtualenv."
		return 2
	end

	#Check if a different env is being used
	if set -q VIRTUAL_ENV
		dvirtualenv
	end

	set -gx VIRTUAL_ENV $VIRTUALENV_HOME/$argv[1]
	set -g _VF_EXTRA_PATH $VIRTUAL_ENV/bin
	set -gx PATH $_VF_EXTRA_PATH $PATH
end

function devirtualenv
	#find elements to remove from PATH
	set to_remove
	for i in (seq (count $PATH))
		if contains $PATH[$i] $_VF_EXTRA_PATH
			set to_remove $to_remove $i
		end
	end

	#remove them
	for i in $to_remove
		set -e PATH[$i]
	end

	set -e VIRTUAL_ENV
end
