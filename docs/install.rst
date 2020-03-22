Installation and Setup
======================

Installing
----------

1. Make sure you are running Fish 3.x. If you are running an Ubuntu LTS
   release that has an older Fish version, install Fish 3.x via the
   `Fish 3.x release series PPA`_.
2. Install VirtualFish by running: ``pip install virtualfish``
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

4. Customize your ``fish_prompt``

Customizing Your ``fish_prompt``
--------------------------------

VirtualFish doesn't attempt to mess with your prompt. Since Fish's
prompt is a function, it is both much less straightforward to change it
automatically, and much more convenient to simply customize it manually
to your liking.

The easiest way to add virtualenv to your prompt is to type
``funced fish_prompt``, add the following line in somewhere:

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
    pip uninstall virtualfish


.. _Fish 3.x release series PPA: https://launchpad.net/~fish-shell/+archive/ubuntu/release-3
