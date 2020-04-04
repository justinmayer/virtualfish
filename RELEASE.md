Release type: minor

* Show warning if activated virtual environment name does not appear in prompt
* *Projects* and *Compatibility Aliases* plugins can be used together without specific loading order
* `compat_aliases` plugin: Only define `deactivate` when a virtual environment is active
* `global_requirements` plugin: Disable per session/invocation via environment variable
* Check `*.fish` file syntax during CI test runs
