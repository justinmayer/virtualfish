Usage
=====

Commands
--------

-  ``vf activate <envname>`` (or ``workon <envname>``\ \*) - Activate a
   virtualenv. (Note: Doesn't use the ``activate.fish`` script provided
   by virtualenv.)
-  ``vf deactivate`` (or ``deactivate``\ \*) - Deactivate the current
   virtualenv.
-  ``vf new [<options>] <envname>`` (or ``mkvirtualenv``\ \*) - Create a
   virtualenv. Note that ``<envname>`` *must be last*.
-  ``vf tmp [<options>]`` (or ``mktmpenv``\ \*) - Create a temprorary
   virtualenv with a randomly generated name that will be removed when
   it is deactivated.
-  ``vf rm <envname>`` (or ``rmvirtualenv``\ \*) - Delete a virtualenv.
-  ``vf ls`` - List the available virtualenvs.
-  ``vf cd`` (or ``cdvirtualenv``\ \*) - Change directory to
   currently-activated virtualenv.
-  ``vf cdpackages`` (or ``cdsitepackages``\ \*) - Change directory to
   the currently-activated virtualenv's site-packages.
-  ``vf addpath`` (or ``add2virtualenv``\ \*) - Add a directory to this
   virtualenv's ``sys.path``.

\*with ``VIRTUALFISH_COMPAT_ALIASES`` switched on - see Configuration
Variables below.

Using Different Pythons
-----------------------

By default, the environments you create with ``virtualenv`` (and, by extension,
virtualfish) use the same Python version that ``virtualenv`` was installed
under, which will usually be whatever your default system Python is.

If you want to use something different in a particular virtualenv, just pass in
the ``-p PYTHON_EXE`` argument to ``vf new``, where ``PYTHON_EXE`` is any Python
executable, for example::

    vf new -p python3 my_python3_env
    vf new -p /usr/bin/pypy my_pypy_env

Configuration Variables
-----------------------

All of these must be set before ``virtual.fish`` is sourced in your
``~/.config/fish/config.fish``.

-  ``VIRTUALFISH_HOME`` (default: ``~/.virtualenvs``) - where all your
   virtualenvs are kept.
-  ``VIRTUALFISH_COMPAT_ALIASES`` - set this to create aliases for
   ``workon`` and ``deactivate`` a la virtualenvwrapper. *Caveat:
   ``deactivate`` exists (and can be overwritten) even when a virtualenv
   is not active.*

If you have pip 1.4+ and have used ``vf requirements`` to add global
requirements that should be installed in all your virtual environments,
adding the following configuration variables to
``~/.config/fish/config.fish`` will significantly speed up the
installation process:

::

    set -x PIP_USE_WHEEL "true"
    set -x PIP_WHEEL_DIR "$HOME/.pip/wheels"
    set -x PIP_FIND_LINKS "file://$HOME/.pip/wheels"
    set -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"

These are standard pip settings and aren't directly related to
virtualfish. The wheels and cache paths can be set to any arbitrary
directories you prefer.
