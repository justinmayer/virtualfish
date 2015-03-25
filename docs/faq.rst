Frequently Asked Questions
==========================

Why isn't Virtualfish written in Python?
----------------------------------------

Mostly, for `the same reasons virtualenvwrapper is <http://virtualenvwrapper.readthedocs.org/en/latest/design.html>`__.

Does Virtualfish work with Python 3? What about PyPy?
-----------------------------------------------------

**Yes!** In fact, you can create Python 3 virtualenvs even if your system Python
is Python 2, or vice versa, using the `--python` argument (see the 'Usage'
section for full details).

Why does Virtualfish use Virtualenv and not pyvenv?
---------------------------------------------------

pyvenv may be the new shiny, but it can only be run from Python 3 and can only
create Python 3 environments. In contrast, virtualenv fully supports Python 2
and 3, as discussed above. So, we can't use pyvenv on its own.

It's been suggested that we could use both, but that would add complexity for no
real benefit. If pyvenv added new, broadly useful features not in virtualenv, or
if virtualenv stopped working on Python 3, or if Python 2 went out of widespread
use, this might change, but for now virtualenv is the best choice.