Release type: major

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
