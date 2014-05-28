Installation and Setup
======================

Installing
----------

1. Make sure you're running Fish 2.x. If you're running an Ubuntu LTS
   release that has an older Fish version, `install Fish 2.x via the
   fish-shell/release-2
   PPA <https://launchpad.net/~fish-shell/+archive/release-2>`__.
2. Source ``virtual.fish`` somewhere in your
   ``~/.config/fish/config.fish``, like this:

   ::

       # set -g VIRTUALFISH_COMPAT_ALIASES # uncomment for virtualenvwrapper-style commands
       . path/to/virtual.fish
       # optional plugins
       . path/to/auto_activation.fish
       . path/to/global_requirements.fish
       . path/to/projects.fish

   The first line is only necessary if you're used to virtualenvwrapper's
   commands (eg ``workon``, ``deactivate`` and so on), and you want virtualfish
   to emulate them.

   *Note:* If your ``config.fish`` modifies your ``$PATH``, you should
   ensure that you source virtualfish *after* those modifications.

3. Customize your ``fish_prompt``

Customizing Your ``fish_prompt``
--------------------------------

virtualfish doesn't attempt to mess with your prompt. Since Fish's
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
