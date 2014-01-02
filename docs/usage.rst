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

Additionally, plugins provide the following commands:

-  ``auto_activation.fish``

   -  ``vf connect`` - Connect the current virtualenv to the current
      directory, so that it is activated automatically as soon as you
      enter it (and deactivated as soon as you leave).

-  ``global_requirements.fish``

   -  ``vf requirements`` - Edit the global requirements file in your
      ``$EDITOR``. Applies the requirements to all virtualenvs on exit.

\*with ``VIRTUALFISH_COMPAT_ALIASES`` switched on - see Configuration
Variables below.

Automatic Activation
--------------------

virtualfish can automatically activate a virtualenv when you are in a
certain directory. To configure it to do so, change to the directory,
activate the desired virtualenv, and run ``vf connect``.

This will save the name of the virtualenv to the file ``.venv``. If you
would prefer to use a different name for this file, you can do so
provided you also set ``VIRTUALFISH_ACTIVATION_FILE`` in
``~/.config/fish/config.fish`` to the same value. For example, for
compatibility with older versions of this script:

::

    set -gx VIRTUALFISH_ACTIVATION_FILE .vfenv

Variables
---------

-  ``VIRTUAL_ENV`` - Path to the currently active virtualenv.

   -  Tips: use ``basename`` to get the virtualenv's name, or ``set -q``
      to see whether a virtualenv is active at all.

-  auto-activation plugin

   -  ``VF_AUTO_ACTIVATED`` - If the currently-activated virtualenv was
      activated automatically, set to the directory that triggered the
      activation. Otherwise unset.

Events
------

virtualfish emits Fish events instead of using hook scripts. To hook in
to events that virtualfish emits, write a function like this:

::

    function myfunc --on-event virtualenv_did_activate
        echo "The virtualenv" (basename $VIRTUAL_ENV) "was activated"
    end

You can save your function using ``funcsave``, put it in
``.config/fish/config.fish``, or put it anywhere Fish will see it before
it needs to run.

Some events are emitted twice, once normally and once with the name of
the virtualenv as part of the event name. This is to make it easier to
listen for events relevant to one specific virtualenv, for example:

::

    function myfunc --on-event virtualenv_did_activate:my_site_env
        set -gx DJANGO_SETTINGS_MODULE mysite.settings
    end

The full list of events is:

-  ``virtualenv_will_activate``
-  ``virtualenv_will_activate:<env name>``
-  ``virtualenv_did_activate``
-  ``virtualenv_did_activate:<env name>``
-  ``virtualenv_will_deactivate``
-  ``virtualenv_will_deactivate:<env name>``
-  ``virtualenv_did_deactivate``
-  ``virtualenv_did_deactivate:<env name>``
-  ``virtualenv_will_create``
-  ``virtualenv_did_create``
-  ``virtualenv_did_create:<env name>``

Configuration Variables
-----------------------

All of these must be set before ``virtual.fish`` is sourced in your
``~/.config/fish/config.fish``.

-  ``VIRTUALFISH_HOME`` (default: ``~/.virtualenvs``) - where all your
   virtualenvs are kept.
-  ``VIRTUALFISH_ACTIVATION_FILE`` (default: ``.venv``) - the name of
   the file virtualfish will use for the auto-activation feature.
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
    set -x PIP_FIND_LINKS "$HOME/.pip/wheels"
    set -x PIP_DOWNLOAD_CACHE "$HOME/.pip/cache"

These are standard pip settings and aren't directly related to
virtualfish. The wheels and cache paths can be set to any arbitrary
directories you prefer.
