Plugins
=======

Virtualfish comes with a number of plugins, which you can use by sourcing the
relevant ``.fish`` files.

Auto-activation
---------------

With this plugin enabled,
virtualfish can automatically activate a virtualenv when you are in a
certain directory. To configure it to do so, change to the directory,
activate the desired virtualenv, and run ``vf connect``.

This will save the name of the virtualenv to the file ``.venv``. Virtualfish
will then look for this file every time you ``cd`` into the directory (or
``pushd``, or anything else that modifies ``$PWD``).

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

Global Requirements
-------------------

Keeps a global ``requirements.txt`` file that is applied to every existing and
new virtualenv.

Commands
........

-  ``vf requirements`` - Edit the global requirements file in your
   ``$EDITOR``. Applies the requirements to all virtualenvs on exit.

Projects
--------

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

Configuration Variables
.......................

-  ``PROJECT_HOME`` (default: ``~/projects/``) - Where to create new projects
   and where to look for existing projects.

Environment variables
---------------------

This plugin adds the capability of automatically setting environment variables
upon activating a virtualenv. Environment variables should be place in a
``.venvvars`` file inside the virtualenv directory. It is also possible to
place this file inside of the project root when the projects plugin is used.
The ``.venvvars`` file in the project root takes precedence over the one in 
the virtualenv directory.

The format of the file is one key value pair per line, separated by a space:

::

    SECRET_KEY mysecretkey
    DEPLOY_ENV development

Environment variables that are currently set and would thus be overwritten
are stored with the prefix: _VF_OLD_. If you have for example alread defined
SECRET_KEY in your current environment then activating the virtualenv would
store that value under _VF_OLD_SECRET_KEY. Upon deactivating the virtualenv
the old values are restored and the _VF_OLD_* variables removed.

Configuration Variables
.......................

-  ``VIRTUALFISH_ENVIRONMENT_VARIABLES_FILE`` (default: ``.venvvars``) - 
  The name of the file containing the environment variables.

-  ``VIRTUALFISH_ENVIRONMENT_VARIABLES_PREFIX`` (default: ``_VF_OLD_``) - 
  Prefix for environment variables that are backed up.
