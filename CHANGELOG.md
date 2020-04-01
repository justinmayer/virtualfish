CHANGELOG
=========

1.0.6 - 2018-01-02
------------------

* Switch to new install process that doesn’t invoke Python on shell session start
* Add _Environment_ plugin to set environment variables upon virtual environment activation
* Add _Update Python_ plugin to upgrade existing virtual environments to newer Python versions
* Add foundation for a test suite

1.0.5 - 2016-10-04
------------------

* Optionally create `$VIRTUALFISH_HOME` directory if it does not exist
* Add `VIRTUALFISH_PYTHON_EXEC` variable to track which Python interpreter was used to install VirtualFish

1.0.3 - 2016-07-01
------------------

* De-activate the currently-active virtual environment, if any, before creating a new one

1.0.1 - 2015-05-03
------------------

* Add `vf cdproject` command to switch to the project directory matching the name of the currently activated virtual environment
* Add `vf togglepackages`, as `toggleglobalsitepackages`, which will enable or disable the visibility of packages installed outside the virtual environment
* Add `VIRTUALFISH_DEFAULT_PYTHON` environment variable to use the specified Python executable as the default Python interpreter to use when creating a new virtual environment
* If set, deactivate `PIP_USER` when a virtual environment is active

1.0.0 - 2015-05-03
------------------

Initial release as versioned package distribution

(unversioned) - 2012-07-01 to 2015-05-03
----------------------------------------

See: https://github.com/justinmayer/virtualfish/compare/3575e05...1.0.0
