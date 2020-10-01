Frequently Asked Questions
==========================

How do I ensure new environments always have the latest version of Pip?
-----------------------------------------------------------------------

You may see warnings from Pip about a newer available version, even on fresh
environments you have just created. To ensure Pip is automatically updated upon
environment creation, enable the *Global Requirements* plugin and add Pip via::

    vf addplugins global_requirements
    echo "pip" >> $VIRTUALFISH_HOME/global_requirements.txt

Why isn’t VirtualFish written in Python?
----------------------------------------

Mostly, for `the same reasons Virtualenvwrapper isn’t`_.

Does VirtualFish work with Python 3? What about PyPy?
-----------------------------------------------------

**Yes!** In fact, you can create Python 3 virtual environments even if your
system Python is Python 2, or vice versa, using the ``--python`` argument
(see the :doc:`Usage <usage>` section for full details).

Why does VirtualFish use Virtualenv and not Python’s built-in ``venv`` module?
------------------------------------------------------------------------------

Virtualenv_ can create both Python 2 and Python 3 virtual environments, whereas
Python’s built-in ``venv`` module can only create Python 3 virtual environments.
That said, since Python 2 is no longer officially supported by the Python
Software Foundation, Python 2 support is a very minor consideration when
deciding which tool to use. The main reason VirtualFish uses Virtualenv_ is due
to its **much** faster speed. We have seen Virtualenv_ create environments in
**one-fifth** the amount of time that the ``venv`` module takes to perform the
same task.

Why doesn’t VirtualFish use activate.fish?
------------------------------------------

VirtualFish uses its own internal virtual environment activation code instead
of the ``activate.fish`` file that Virtualenv_ generates for two main reasons.
One is that when VirtualFish was originally written, ``activate.fish`` didn't
actually work. The second reason, which is still valid today, is that
``activate.fish`` tries to modify your ``fish_prompt`` function.

Because ``fish_prompt`` is a function and not a variable like in most other
shells, modifying it programmatically is not trivial, and the way that
Virtualenv_ accomplishes it is more than a little hacky. The benefit of it being
a function is that the syntax for customising it is much less terse and cryptic
than, say, ``PS1`` on Bash. This is why VirtualFish doesn’t attempt to modify
your prompt, and instead tells you how to do it yourself.

.. _Virtualenv: https://virtualenv.pypa.io/
.. _the same reasons Virtualenvwrapper isn’t: https://virtualenvwrapper.readthedocs.io/en/latest/design.html
