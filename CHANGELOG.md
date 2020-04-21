CHANGELOG
=========

2.2.1 - 2020-04-21
------------------

Running `vf ls` no longer modifies directory history

2.2.0 - 2020-04-08
------------------

* `rm`: Allow multiple virtual environment deletion with single invocation
* `auto_activation`: After `vf connect`, de-activate when leaving project directory
* Remove unnecessary `xdg` Python dependency

2.1.0 - 2020-04-04
------------------

* Show warning if activated virtual environment name does not appear in prompt
* *Projects* and *Compatibility Aliases* plugins can be used together without specific loading order
* `compat_aliases` plugin: Only define `deactivate` when a virtual environment is active
* `global_requirements` plugin: Disable per session/invocation via environment variable
* Check `*.fish` file syntax during CI test runs

2.0.1 - 2020-04-02
------------------

* Ensure `vf addpath <path>` is compatible with Python 3
* Improve `vf activate` $PATH handling durability

2.0.0 - 2020-04-01
------------------

* First release under new stewardship by [Justin Mayer](https://justinmayer.com/)
* Find & use non-PATH Python interpreters via common paths/tools (Pyenv, Pythonz, etc.)
* Environment name no longer must be passed as last argument to `vf new` or `vf project`
* Add `--help` to `vf new` and `vf project`
* Manage `vf new` verbosity via `--quiet`, `--verbose`, & `--debug` options
* Upon environment activation, if `$VIRTUALENV/.project` exists, `cd` to directory specified within
* Use `trash` command (if available) to safely remove environments via `vf rm`
* Improve install command UX and add uninstall command
* Improve API of Fish subprocess control class
* Add tests for `vf activate`, `vf deactivate`, and `vf rm`
* Automate tests via GitHub Actions CI
* Automatically publish package releases upon PR merge via [AutoPub](https://github.com/autopub/autopub)
* Ensure external `cat` and `rm` command invocations are not aliased
* Fix autocomplete help text when `functions` prints comments
* Overhaul documentation

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
