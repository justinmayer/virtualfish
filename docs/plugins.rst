Plugins
=======

Virtualfish comes in-built with a number of plugins.

You can use them by passing their names in as arguments to the virtualfish
loader in your ``config.fish``, e.g.::

   eval (python -m virtualfish auto_activation global_requirements)

.. _compat_aliases:

Virtualenvwrapper Compatibility Aliases (``compat_aliases``)
------------------------------------------------------------

This plugin provides some global commands to make virtualfish behave more like
Doug Hellman's virtualenvwrapper.

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

Auto-activation (``auto_activation``)
--------------------------------------

With this plugin enabled,
virtualfish can automatically activate a virtualenv when you are in a
certain directory. To configure it to do so, change to the directory,
activate the desired virtualenv, and run ``vf connect``.

This will save the name of the virtualenv to the file ``.venv``. Virtualfish
will then look for this file every time you ``cd`` into the directory (or
``pushd``, or anything else that modifies ``$PWD``).


.. note::

    When this plugin is enabled, ensure any modifications to your ``$PATH`` in
    your ``config.fish`` happen before virtualfish is loaded.

Commands
........

-  ``vf connect`` - Connect the current virtualenv to the current
   directory, so that it is activated automatically as soon as you
   enter it (and deactivated as soon as you leave).

Configuration Variables
.......................

-  ``VIRTUALFISH_ACTIVATION_FILE`` (default: ``.venv``) - the name of
   the file virtualfish will use for the auto-activation feature. Earlier
   versions of virtualfish used ``.vfenv``.

State Variables
...............

-  ``VF_AUTO_ACTIVATED`` - If the currently-activated virtualenv was
   activated automatically, set to the directory that triggered the
   activation. Otherwise unset.

Global Requirements (``global_requirements``)
---------------------------------------------

Keeps a global ``requirements.txt`` file that is applied to every existing and
new virtualenv.

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

Commands
........

-  ``vf project <name>`` - Create a new project and matching virtual environment
   with the specified name. This name **must** be the last parameter (i.e.,
   after ``-p python3`` or any other arguments destined for the ``virtualenv``
   command). If ``VIRTUALFISH_COMPAT_ALIASES`` is set, ``mkproject`` is aliased
   to this command.

-  ``vf workon <name>`` - Search for a project and/or virtualenv matching the
   specified name. If found, this activates the appropriate virtualenv and
   switches to the respective project directory. If ``VIRTUALFISH_COMPAT_ALIASES``
   is set, ``workon`` is aliased to this command.

-  ``vf lsprojects`` - List projects available in ``$PROJECT_HOME`` (see below)

-  ``vf cdproject`` - Search for a project matching the name of the currently
   activated virtualenv. If found, this switches to the respective project
   directory. If ``VIRTUALFISH_COMPAT_ALIASES`` is set, ``cdproject`` is aliased
   to this command.

Configuration Variables
.......................

-  ``PROJECT_HOME`` (default: ``~/projects/``) - Where to create new projects
   and where to look for existing projects.
