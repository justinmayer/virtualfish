Usage
=====

Commands
--------

-  ``vf new [<options>] <envname>`` - Create a virtual environment.
-  ``vf ls [--details]`` - List the available virtual environments.
-  ``vf activate <envname>`` - Activate a virtual environment. (Note: Doesn’t
   use the ``activate.fish`` script provided by Virtualenv_.)
-  ``vf deactivate`` - Deactivate the current virtual environment.
-  ``vf upgrade [<options>] [<envname(s)>]`` - Upgrade virtual environment(s).
-  ``vf rm <envname>`` - Delete a virtual environment.
-  ``vf tmp [<options>]`` - Create a temporary virtual environment with a
   randomly generated name that will be removed when it is deactivated.
-  ``vf cd`` - Change directory to currently-activated virtual environment.
-  ``vf cdpackages`` - Change directory to currently-active virtual
   environment’s site-packages.
-  ``vf globalpackages`` - Toggle system site packages.
-  ``vf addpath`` - Add a directory to this virtual environment’s ``sys.path``.
-  ``vf all <command>`` - Run a command in all virtual environments sequentially.
-  ``vf connect [<envname>]`` - Connect the current working directory with the
   currently active (or specified) virtual environment. This requires the
   :ref:`auto-activation plugin <auto_activation>` to be enabled in order to
   have any effect besides creating a :file:`.venv` file in the current directory.

If you are accustomed to virtualenvwrapper_ commands (``workon``, etc.), you may
wish to enable the :ref:`compat_aliases` plugin.

Using Different Pythons
-----------------------

By default, the environments you create with VirtualFish will use the same
Python version that was originally used to Pip-install VirtualFish, which will
usually be your system’s default Python interpreter.

If you want to create a new virtual environment with a different Python
interpreter, add the ``--python PYTHON_EXE`` (``-p`` for brevity) flag to
``vf new``, where ``PYTHON_EXE`` is any Python executable. For example::

    vf new -p /usr/bin/python3 my_python3_env

Specifying the full path to the Python executable avoids ambiguity and is thus
the most reliable option, but if the target Python executable is on your
``PATH``, you can save a few keystrokes and pass the bare executable instead::

    vf new -p pypy my_pypy_env

Sometimes there may be Python interpreters on your system that are not on your
``PATH``, with full filesystem paths that are long and thus hard to remember and
type. VirtualFish makes dealing with these easier by automatically detecting and
using Python interpreters in a few known situations, in the following order:

1. asdf_ Python plugin is installed and has built the specified Python version.
2. Pyenv_ is installed and has built the specified Python version.
3. Pythonz_ is installed and has built the specified Python version.
4. Python.org_ Mac installation of specified Python version (e.g., 3.10) found
   at: ``/Library/Frameworks/Python.framework/Versions``.
5. Homebrew_ keg-only versioned Python executable (e.g., 3.8) found at:
   ``/usr/local/opt/python@3.8/bin/python3.8``.

For asdf_, Pyenv_, and Pythonz_ , in addition to passing option flags such as
``-p python3.8`` or ``-p python3.9.0a4``, you can even get away with specifying
just the version numbers, such as ``-p 3.8`` or ``-p 3.9.0a4``. Python.org_
versions should be specified with Major.Minor version numbers, such as
``-p 3.10``.

.. _configuration_variables:

Upgrading Virtual Environments
------------------------------

Virtual environments contain links to Python interpreters that can become
outdated over time. In addition, sometimes the underlying Python interpreter
can be removed by Python upgrades, putting the virtual environment into an
unusable state. Thankfully, VirtualFish includes a mechanism for upgrading
outdated/broken environments.

To understand which environments might be outdated/broken, run::

    vf ls --details

You can maintain a list of target Python versions via a line such as the
following in a ``~/.tool-versions`` file::

    python 3.9.7 3.8.12 3.7.11 3.6.14

Environment Python versions that match one of those versions will be shown as
up-to-date (green). If target Python versions are not specified in that file,
VirtualFish compares environment Python versions to the current default Python
version, as specified by the ``VIRTUALFISH_DEFAULT_PYTHON`` variable (see
below), if defined. To perform a minor (point-release) upgrade to the
currently-active virtual environment, run::

    vf upgrade

Minor point-release upgrades will modify in-place the virtual environment’s
Python version number and symlinks. (While this should work correctly in the
majority of cases, there is the possibility that future changes to virtual
environment structure will interfere with this in-place upgrade.)

For major version upgrades, say from Python 3.8.x to 3.9.x, you must instead
re-build the environment via::

    vf upgrade --rebuild

Re-building an environment will record its current package versions, remove the
old environment, create a new environment with the same name, and re-install the
list of recorded package versions.

If VirtualFish determines that a virtual environment is in a broken state, it
will re-build that environment, even if ``--rebuild`` is omitted.

To upgrade to a specific Python interpreter or version, use the ``--python``
option::

    vf upgrade --rebuild --python /usr/local/bin/python3.8

Virtual environments need not be active in order to upgrade them. To upgrade
one or more virtual environments, specify their names::

    vf upgrade project1 project2

Upgrades can also be applied to all environments. To re-build all existing
environments::

    vf upgrade --rebuild --all

Configuration Variables
-----------------------

The ``vf install […]`` installation step writes the VirtualFish loader to a file
at ``$XDG_CONFIG_HOME/fish/conf.d/virtualfish-loader.fish``, which on most
systems defaults to: ``~/.config/fish/conf.d/virtualfish-loader.fish``

You can edit this file to, for example, change the plugin loading order. You can
also add the following optional variables at the top, so that they are set
before ``virtual.fish`` is sourced.

-  ``VIRTUALFISH_HOME`` (default: ``~/.virtualenvs``) - where all your
   virtual environments are kept.
-  ``VIRTUALFISH_DEFAULT_PYTHON`` - The default Python interpreter to use when
   creating a new virtual environment; the value should be a valid argument to
   the Virtualenv_ ``--python`` flag.

Regardless of the changes that you make, you must run ``exec fish`` afterward if
you want those changes to take effect for the current shell session.


.. _virtualenvwrapper: https://bitbucket.org/dhellmann/virtualenvwrapper
.. _Virtualenv: https://virtualenv.pypa.io/en/latest/
.. _Homebrew: https://docs.brew.sh/Homebrew-and-Python
.. _asdf: https://asdf-vm.com/
.. _Pyenv: https://github.com/pyenv/pyenv
.. _Pythonz: https://github.com/saghul/pythonz
.. _Python.org: https://www.python.org/downloads/macos/
