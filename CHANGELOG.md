CHANGELOG
=========

2.5.8 - 2024-04-25
------------------

Resolve compatibility issue with Python 3.12

Contributed by [Branch Vincent](https://github.com/branchvincent) via [PR #244](https://github.com/justinmayer/virtualfish/pull/244/)


2.5.7 - 2024-03-12
------------------

Fix `vf upgrade` error related to `sed`

2.5.6 - 2024-03-07
------------------

Improve resiliency of `check_fish_version()` function to invisible characters such as tabs.

Contributed by [Justin Mayer](https://github.com/justinmayer) via [PR #241](https://github.com/justinmayer/virtualfish/pull/241/)


2.5.5 - 2022-07-21
------------------

* Raise minimum Python version to 3.7
* Remove upper bounds on dependency versions

2.5.4 - 2021-09-07
------------------

* Use tool versions file to colorize `ls --details` ([#212](https://github.com/justinmayer/virtualfish/pull/212) by [Justin Mayer](https://justinmayer.com/))
* _[`auto_activation`]_: Fix bug that auto-deactivated environments incorrectly ([#210](https://github.com/justinmayer/virtualfish/pull/210) by [@cecep2](https://github.com/cecep2))

2.5.3 - 2021-06-29
------------------

* Preserve `.project` files when re-building environments ([#206](https://github.com/justinmayer/virtualfish/pull/206))
* Improve Pyenv version detection ([#208](https://github.com/justinmayer/virtualfish/pull/208))
* _[`auto_activation`]_: Auto-deactivate environments in `$PROJECT_HOME` without requiring `.project` files ([#209](https://github.com/justinmayer/virtualfish/pull/209))
* Improve installation instructions ([#207](https://github.com/justinmayer/virtualfish/pull/207))

Many thanks to [@cecep2](https://github.com/cecep2) for all of the above improvements!

2.5.2 - 2021-06-07
------------------

* `vf connect`: Accept an (optional) virtualenv name argument to connect (and activate)

2.5.1 - 2020-12-01
------------------

* globalpackages: Can now explicitly enable, disable, or toggle global packages
* auto_activation: Auto-activate only for interactive sessions

2.5.0 - 2020-09-03
------------------

* `vf upgrade`: New command for upgrading and re-building environments (#141)
* `vf ls`: Add `--details` flag to show Python status and version numbers (#190)
* `vf --help`: Add dynamic column spacing
* `vf all`: Show environment name before command output
* Add `__vfsupport_check_python` function to ensure Python interpreters work
* Demote Homebrew Python priority when locating interpreters

2.4.0 - 2020-07-22
------------------

* Remove temporary environments *safely* upon de-activation
* Replace $HOME with ~ when displaying new virtual environment path
* Environment: support .project files, loading .env from corresponding project

2.3.0 - 2020-06-08
------------------

* Enable/disable plugins via new `addplugins` & `rmplugins` sub-commands (#178)
* Fish prompt check added in v2.1 now also checks `$fish_right_prompt` (#182)
* Setting environment variable `VIRTUAL_ENV_DISABLE_PROMPT=1` disables the prompt check

2.2.5 - 2020-05-29
------------------

* Projects + Auto-Activation: Auto-deactivate when leaving project directory
* global_requirements: Don't manually build wheels
* Fix erroneous minimum Fish version

2.2.4 - 2020-05-28
------------------

Improve Fish version check reliability. Upon failure, warn instead of exiting.

2.2.3 - 2020-05-16
------------------

* Ensure minimum required Fish shell version is present when installing
* Prevent error on older Fish shell versions

2.2.2 - 2020-05-06
------------------

When uninstalling, use same Python interpreter used to install VirtualFish

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
