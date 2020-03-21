Extending VirtualFish
=====================

Variables
---------

Virtualenv currently provides one global variable to allow you to inspect its
state. (Keep in mind that more are provided by plugins.)

-  ``VIRTUAL_ENV`` - Path to the currently active virtualenv.

   -  Tips: use ``basename`` to get the virtualenv's name, or ``set -q``
      to see whether a virtualenv is active at all.


Events
------

VirtualFish emits Fish events instead of using hook scripts. To hook into
events that VirtualFish emits, write a function like this:

::

    function myfunc --on-event virtualenv_did_activate
        echo "The virtualenv" (basename $VIRTUAL_ENV) "was activated"
    end

You can save your function by putting it in ``.config/fish/config.fish``, or
put it anywhere Fish will see it before it needs to run. (Note: saving it with
``funcsave`` won't work.)

Some events are emitted twice, once normally and once with the name of
the virtualenv as part of the event name. This is to make it easier to
listen for events relevant to one specific virtualenv, for example:

::

    function myfunc --on-event virtualenv_did_activate:my_site_env
        set -gx DJANGO_SETTINGS_MODULE mysite.settings
    end

The full list of events is:

-  ``virtualenv_did_setup_plugins``
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
