Plugins
=======

VirtualFish comes with a number of built-in plugins.

You can use them by passing their names as arguments to the ``vf install``
command. For example, the following will activate the ``compat_aliases``,
``projects``, and ``environment`` plugins::

    vf install compat_aliases projects environment

.. _compat_aliases:

Virtualenvwrapper Compatibility Aliases (``compat_aliases``)
------------------------------------------------------------

This plugin provides some global commands to make VirtualFish behave more like
Doug Hellman’s virtualenvwrapper_.

Commands
........


-  ``workon <envname>`` = ``vf activate <envname>``
-  ``deactivate`` = ``vf deactivate``
-  ``mkvirtualenv [<options>] <envname>`` = ``vf new [<options>] <envname>``
-  ``mktmpenv [<options>]`` = ``vf tmp [<options>]``
-  ``rmvirtualenv`` = ``vf rm <envname>``
-  ``lsvirtualenv`` = ``vf ls``
-  ``cdvirtualenv`` = ``vf cd``
-  ``cdsitepackages`` = ``vf cdpackages``
-  ``add2virtualenv`` = ``vf addpath``
-  ``allvirtualenv`` = ``vf all``
-  ``setvirtualenvproject`` = ``vf connect``


.. _auto_activation:

Auto-activation (``auto_activation``)
--------------------------------------

With this plugin enabled, VirtualFish can automatically activate a virtualenv
when you are in a certain directory. To configure it to do so, change to the
directory, activate the desired virtualenv, and run ``vf connect``.

This will save the name of the virtualenv to a file named ``.venv``.
VirtualFish will then look for this file every time you ``cd`` into the
directory (or ``pushd``, or anything else that modifies ``$PWD``).


.. note::

    When this plugin is enabled, ensure any environment variables that affect
    VirtualFish are set as noted in :ref:`configuration_variables` and not in
    ``config.fish``. Files in ``~/.config/fish/conf.d/`` (including VirtualFish)
    are sourced *before* ``config.fish``, and thus variables set in
    ``config.fish`` may not be available to VirtualFish.

Commands
........

-  ``vf connect`` - Connect the current virtualenv to the current
   directory, so that it is activated automatically as soon as you
   enter it (and deactivated as soon as you leave).

Configuration Variables
.......................

-  ``VIRTUALFISH_ACTIVATION_FILE`` (default: ``.venv``) - the name of
   the file VirtualFish will use for the auto-activation feature. Earlier
   versions of VirtualFish used ``.vfenv``.

State Variables
...............

-  ``VF_AUTO_ACTIVATED`` - If the currently-activated virtualenv was
   activated automatically, set to the directory that triggered the
   activation. Otherwise unset.

Global Requirements (``global_requirements``)
---------------------------------------------

Keeps a global ``requirements.txt`` file that is applied to every existing and
new virtual environment. This behavior can be disabled for a given session by
setting the ``VIRTUALFISH_GLOBAL_REQUIREMENTS`` environment variable to "0".
To disable on a per-invocation basis, prefix commands with the same variable::

    VIRTUALFISH_GLOBAL_REQUIREMENTS="0" vf tmp

Commands
........

-  ``vf requirements`` - Edit the global requirements file in your
   ``$EDITOR``. Applies the requirements to all virtualenvs on exit.

Projects (``projects``)
-----------------------

This plugin adds project management capabilities, including automatic directory
switching upon virtual environment activation. Typically a project directory
contains files — such as source code managed by a version control system — that
are often stored separately from the virtual environment.

The following example will create a new project, with a matching virtual
environment, both named ``YourProject``::

    vf project YourProject

The above command performs the following tasks:

1. creates new empty project directory in ``PROJECT_HOME`` (if there is no
   existing ``YourProject`` directory within) and changes the current working
   directory to it
2. creates new virtual environment named ``YourProject`` and activates it

To work on an existing project, use the ``vf workon <name>`` command to activate
the specified virtual environment and change the current working directory to
the project of the same name. For cases in which the project name differs from
the target virtualenv name, you can manually specify which virtualenv should be
activated for a given project by creating a ``.venv`` file inside the project
root containing the name of the corresponding virtualenv.

If you use sub-folders, have projects located outside of ``PROJECT_HOME``, or
utilize a project organization strategy that does not lend itself to storing
all your projects in the root of a single directory, you may navigate to your
project and associate the current working directory with the currently-activated
virtual environment via the following example steps::

   vf activate YourVirtualenv
   cd /path/to/your/project
   echo $PWD > $VIRTUALENV/.project

In the future, you may then run ``vf workon YourVirtualenv`` to simultaneously
activate ``YourVirtualenv`` and switch to the ``/path/to/your/project``
directory.

.. note::


    If you are using both the *Compatibility Aliases* and *Projects* plugins,
    ``workon`` will alias ``vf workon`` instead of ``vf activate``.
    If you are using both the *Auto-activation* and *Projects* plugins, the
    project's virtual environment will be deactivated automatically when you
    leave the project's directory.


Commands
........

-  ``vf project <virtualenv-options> <name>`` - Create a new project and
   matching virtual environment with the specified name and Virtualenv options,
   including the ability to specify a Python interpreter via ``--python``.
   If the ``compat_aliases`` plugin is enabled, ``mkproject`` is aliased to
   this command.

-  ``vf workon <name>`` - Search for a project and/or virtualenv matching the
   specified name. If found, this activates the appropriate virtualenv and
   switches to the respective project directory. If the ``compat_aliases``
   plugin is enabled, ``workon`` is aliased to this command.

-  ``vf lsprojects`` - List projects available in ``$PROJECT_HOME`` (see below)

-  ``vf cdproject`` - Search for a project matching the name of the currently
   activated virtualenv. If found, this switches to the respective project
   directory. If the ``compat_aliases`` plugin is enabled, ``cdproject`` is
   aliased to this command.

Configuration Variables
.......................

-  ``PROJECT_HOME`` (default: ``~/projects/``) - Where to create new projects
   and where to look for existing projects.


Environment Variables (``environment``)
---------------------------------------

This plugin provides the ability to automatically set environment variables
when a virtual environment is activated. The environment variables are stored
in a ``.env`` file by default. This can be configured by setting
``VIRTUALFISH_ENVIRONMENT_FILE`` to the desired file name. When using the
`Projects (projects)`_ plugin, the env file is stored in the project
directory unless it is manually created in the ``$VIRTUAL_ENV`` directory. If
the projects plugin isn't being used, the file is stored in the ``$VIRTUAL_ENV``
directory.

When the virtualenv is activated, the values in the env file will be added to
the environment. If a variable with that name already exists, that value is
stored in ``__VF_ENVIRONMENT_OLD_VALUE_$key``.

When the virtual environment is deactivated, if there was a pre-existing value
it is returned to the environment. Otherwise, the variable is erased.

The format of the env file is one key-value set per line separated by an ``=``.
Empty lines are ignored, as are any lines that start with ``#``. See the
following::

    # This is a valid comment and declaration
    FOO=bar

    # The empty line above is valid
    BAR=baz  # Inline comments like this one are NOT okay

Commands
........

- ``vf environment`` - Open the environment file for the active virtual
  environment in ``$VISUAL``/``$EDITOR``, or ``vi`` if neither variable is set.

Update Python (``update_python``)
---------------------------------

This plugin adds commands to change the Python interpreter of the current
virtual environment.

Commands
........

-  ``vf update_python [<python_exe>]`` - Remove the current virtual environment
   and create a new one with ``<python_exe>`` (defaults to
   ``VIRTUALFISH_DEFAULT_PYTHON`` if it is set, or the first executable named
   ``python`` in your ``PATH``), and then re-install the same versions of all
   packages with Pip.

-  ``vf fix_python [<python_exe>]`` - Test the current virtual environment’s
   Python executable. If it doesn't work, update it with ``vf update_python
   [<python_exe>]``. This may be useful when one of your system’s Python
   executables is updated, which may break some of your virtual environments.
   In that case, you probably just need to run: ``vf all vf fix_python``

Configuration Variables
.......................

-  ``VIRTUALFISH_DEFAULT_PYTHON`` (default: ``python``) - The Python
   interpreter to use if not specified as an argument to the above commands.


.. _virtualenvwrapper: https://bitbucket.org/dhellmann/virtualenvwrapper
