Usage
=====

Commands
--------

-  ``vf new [<options>] <envname>`` - Create a virtual environment.
-  ``vf ls`` - List the available virtual environments.
-  ``vf activate <envname>`` - Activate a virtual environment. (Note: Doesn’t
   use the ``activate.fish`` script provided by Virtualenv_.)
-  ``vf deactivate`` - Deactivate the current virtual environment.
-  ``vf rm <envname>`` - Delete a virtual environment.
-  ``vf tmp [<options>]`` - Create a temporary virtual environment with a
   randomly generated name that will be removed when it is deactivated.
-  ``vf cd`` - Change directory to currently-activated virtual environment.
-  ``vf cdpackages`` - Change directory to currently-active virtual
   environment’s site-packages.
-  ``vf globalpackages`` - Toggle system site packages.
-  ``vf addpath`` - Add a directory to this virtual environment’s ``sys.path``.
-  ``vf all <command>`` - Run a command in all virtual environments sequentially.
-  ``vf connect`` - Connect the current working directory with the currently
   active virtual environment. This requires the :ref:`auto-activation plugin
   <auto_activation>` to be enabled in order to have any effect besides creating
   a :file:`.venv` file in the current directory.

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
4. Homebrew_ keg-only versioned Python executable (e.g., 3.8) found at:
   ``/usr/local/opt/python@3.8/bin/python3.8``

For asdf_, Pyenv_, and Pythonz_ , in addition to passing option flags such as
``-p python3.8`` or ``-p python3.9.0a4``, you can even get away with specifying
just the version numbers, such as ``-p 3.8`` or ``-p 3.9.0a4``.

.. _configuration_variables:

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
