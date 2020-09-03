Release type: minor

* `vf upgrade`: New command for upgrading and re-building environments (#141)
* `vf ls`: Add `--details` flag to show Python status and version numbers (#190)
* `vf --help`: Add dynamic column spacing
* `vf all`: Show environment name before command output
* Add `__vfsupport_check_python` function to ensure Python interpreters work
* Demote Homebrew Python priority when locating interpreters
