from sys import argv
import psutil
from subprocess import check_output
import os
from xdg import XDG_CONFIG_HOME

from virtualfish.loader import load, installer


def install():
    if "--help" in argv or "-h" in argv:
        print("Usage: vf install [<plugin> ...]")
        exit()
    installer.install(argv[2:])


def main():
    if len(argv) >= 2 and argv[1] == "install":
        install()
        print("VirtualFish is now installed! Run 'exec fish' to reload "
              "Fish, and you'll be able to use it!")
    else:
        # Display an error, prompting the user to either run vf install (if
        # they're using Fish) or
        this_proc = psutil.Process()
        parent = psutil.Process(this_proc.ppid())
        the_shell = parent.cmdline()[0]
        if the_shell.endswith('fish'):
            print("VirtualFish is not installed. Run 'vf install' to install "
                  "it, then run 'exec fish' to restart your shell and "
                  "load it.")
        else:
            print("VirtualFish isn't compatible with {}, only Fish.".format(the_shell))

if __name__ == "__main__":
    main()
