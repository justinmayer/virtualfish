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
