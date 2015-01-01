function __vfext_global_requirements --on-event virtualenv_did_create
    if test -f $VIRTUALFISH_HOME/global_requirements.txt
        pip install -U -r $VIRTUALFISH_HOME/global_requirements.txt
    end
end

function __vf_requirements --description "Edit the global requirements file for all virtualenvs"
    eval $EDITOR $VIRTUALFISH_HOME/global_requirements.txt
    pushd $VIRTUALFISH_HOME
    # If the user has set up wheels, make sure we build wheels of all the deps
    # prior to trying to install them, so as to speed things up
    if set -q PIP_USE_WHEEL
        pip wheel -r $VIRTUALFISH_HOME/global_requirements.txt
    end
    for i in */bin/pip
        eval $i install -U -r $VIRTUALFISH_HOME/global_requirements.txt
    end
    popd
end

