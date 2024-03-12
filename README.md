# VirtualFish

[![Build Status](https://img.shields.io/github/actions/workflow/status/justinmayer/virtualfish/main.yml?branch=main)](https://github.com/justinmayer/virtualfish/actions)
[![PyPI Version](https://img.shields.io/pypi/v/virtualfish)](https://pypi.org/project/virtualfish/)
[![Downloads](https://img.shields.io/pypi/dm/virtualfish)](https://pypi.org/project/virtualfish/)

VirtualFish is a Python [virtual environment][Virtualenv] manager for the [Fish shell][].

You can get started by [reading the documentation][Read The Docs]. (It’s quite short… Promise!)

You can also get help on [#virtualfish on OFTC](https://webchat.oftc.net/?randomnick=1&channels=virtualfish) (`ircs://irc.oftc.net:6697/#virtualfish`), the same network as the [Fish IRC channel](https://webchat.oftc.net/?randomnick=1&channels=fish).

VirtualFish is maintained by [Justin Mayer](https://justinmayer.com/), and was originally created by [Daisy Leigh Brenecki](https://daisy.wtf).

## A quickstart, for the impatient

👉 **Fish version 3.1 or higher is required.** 👈

1. `python -m pip install virtualfish`
2. `vf install`
3. [Add VirtualFish to your prompt](https://virtualfish.readthedocs.org/en/latest/install.html#customizing-your-fish-prompt)
4. `vf new myvirtualenv; which python`

[Read the documentation][Read The Docs] to find out more about project management, environment variable automation, auto-activation, and other plugins, as well as extending VirtualFish with events, [virtualenvwrapper][] emulation, and more.


[Virtualenv]: https://virtualenv.pypa.io/en/latest/
[Fish shell]: https://fishshell.com/
[Read The Docs]: https://virtualfish.readthedocs.org/en/latest/
[virtualenvwrapper]: https://bitbucket.org/virtualenvwrapper/virtualenvwrapper
