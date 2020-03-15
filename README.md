# virtualfish

[![Build Status](https://img.shields.io/github/workflow/status/justinmayer/virtualfish/build)](https://github.com/justinmayer/virtualfish/actions)

A Fish Shell wrapper for Ian Bicking's [virtualenv](https://virtualenv.pypa.io/en/latest/), somewhat loosely based on Doug Hellman's [virtualenvwrapper](https://bitbucket.org/dhellmann/virtualenvwrapper) for Bourne-compatible shells.

You can get started by [reading the documentation on Read The Docs](http://virtualfish.readthedocs.org/en/latest/). (It's quite short, I promise.)

You can also get help on [#virtualfish on OFTC](https://webchat.oftc.net/?randomnick=1&channels=virtualfish) (`ircs://irc.oftc.net:6697/#virtualfish`), the same network as the [Fish IRC channel](https://webchat.oftc.net/?randomnick=1&channels=fish).

Virtualfish is currently maintained by [Justin Mayer](https://justinmayer.com/), and was originally created by [Leigh Brenecki](https://leigh.net.au/).

## A quickstart, for the impatient

1. `pip install virtualfish`
2. Edit `~/.config/fish/config.fish`, adding a line that reads `eval (python -m virtualfish)`
2. [Add virtualfish to your prompt](http://virtualfish.readthedocs.org/en/latest/install.html#customizing-your-fish-prompt)
2. `vf new myvirtualenv; which python`

See the docs to find out more about virtualenvwrapper emulation, auto-activation and other plugins, extending virtualfish with events, and more.
