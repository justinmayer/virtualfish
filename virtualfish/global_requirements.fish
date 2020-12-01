function __vfext_global_requirements --on-event virtualenv_did_create --description "Install global requirements when new virtual environment is created"
    if begin; test -f $VIRTUALFISH_HOME/global_requirements.txt; and test "$VIRTUALFISH_GLOBAL_REQUIREMENTS" != "0"; end
        echo "Installing global requirements..."
        pip install -U -r $VIRTUALFISH_HOME/global_requirements.txt
    end
end

function __vf_requirements --description "Edit the global requirements file and install contents into *all* virtual environments"
    eval $EDITOR $VIRTUALFISH_HOME/global_requirements.txt
    pushd $VIRTUALFISH_HOME
    for i in */bin/pip
        echo "Installing global requirements via" $i "..."
        eval $i install -U -r $VIRTUALFISH_HOME/global_requirements.txt
    end
    popd
end
