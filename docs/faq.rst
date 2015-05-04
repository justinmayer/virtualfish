Frequently Asked Questions
==========================

Why isn't Virtualfish written in Python?
----------------------------------------

Mostly, for `the same reasons virtualenvwrapper is <http://virtualenvwrapper.readthedocs.org/en/latest/design.html>`__.

Does Virtualfish work with Python 3? What about PyPy?
-----------------------------------------------------

**Yes!** In fact, you can create Python 3 virtualenvs even if your system Python
is Python 2, or vice versa, using the ``--python`` argument (see the :doc:`Usage
<usage>` section for full details).

Why does Virtualfish use Virtualenv and not pyvenv?
---------------------------------------------------

pyvenv may be the new shiny, but it can only be run from Python 3 and can only
create Python 3 environments. In contrast, virtualenv fully supports Python 2
and 3, as discussed above. So, we can't use pyvenv on its own.

It's been suggested that we could use both, but that would add complexity for no
real benefit. If pyvenv added new, broadly useful features not in virtualenv, or
if virtualenv stopped working on Python 3, or if Python 2 went out of widespread
use, this might change, but for now virtualenv is the best choice.

Why doesn't Virtualfish use activate.fish?
------------------------------------------

Virtualfish uses its own internal virtualenv activation code instead of the
``activate.fish`` file that comes with every virtualenv for two main reasons.
One is that when Virtualfish was originally written, ``activate.fish`` didn't
actually work. The second reason, which is still valid today, is that
``activate.fish`` tries to modify your ``fish_prompt`` function.

Because ``fish_prompt`` is a function and not a variable like in most other
shells, modifying it programmatically is not trivial, and the way that
virtualenv accomplishes it is more than a little hacky. The benefit of it being
a function is that the syntax for customising it is much less terse and cryptic
than, say, ``PS1`` on Bash. This is why Virtualfish doesn't attempt to modify
your prompt, and instead tells you how to do it yourself.
