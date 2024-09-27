Installation and Setup
======================

Installing
----------

1. Make sure you are running Fish 3.1+. If you are running an Ubuntu LTS
   release that has an older Fish version, install Fish via the
   `Fish 3.x release series PPA`_.

2. The recommended way to install VirtualFish is to first install `Pipx`_ and
   then run::

       pipx install virtualfish
       pipx ensurepath

   Alternatively, you can first install `uv`_ and then run::

       uv tool install virtualfish
       uv tool update-shell

   Yet another option is to use Pip::

       python -m pip install --user virtualfish
       fish_add_path (python3 -c "import site; print(site.USER_BASE)")/bin

3. Install the VirtualFish loader by running:

   ::

       vf install

   If you want to use VirtualFish with :doc:`plugins <plugins>`, list
   the names of the plugins as arguments to the install command:

   ::

       vf install compat_aliases projects environment

   *Note:* After performing the above step, you will be prompted to run
   ``exec fish`` in order to make these changes active in your current
   shell session.

4. Customize your ``fish_prompt`` as described below.

Customizing Your ``fish_prompt``
--------------------------------

VirtualFish doesn’t attempt to mess with your prompt. Since Fish’s
prompt is a function, it is both much less straightforward to change it
automatically, and much more convenient to simply customize it manually
to your liking.

The easiest way to add the active virtual environment’s name to your prompt is
to type ``funced fish_prompt`` and add the following line somewhere:

::

    if set -q VIRTUAL_ENV
        echo -n -s (set_color -b blue white) "(" (basename "$VIRTUAL_ENV") ")" (set_color normal) " "
    end

Then, type ``funcsave fish_prompt`` to save your new prompt to disk.

Un-installing
-------------

To un-install VirtualFish, run:

::

    vf uninstall
    python -m pip uninstall virtualfish


.. _Fish 3.x release series PPA: https://launchpad.net/~fish-shell/+archive/ubuntu/release-3
.. _Pipx: https://pipx.pypa.io/
.. _uv: https://docs.astral.sh/uv/
