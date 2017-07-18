from sys import argv
import psutil
from subprocess import check_output
import os
from xdg import XDG_CONFIG_HOME

from virtualfish.loader import load


def install():
    if "--help" in argv or "-h" in argv:
        print("Usage: vf install [<plugin> ...]")
        exit()

    # Calculate the script to write.
    lines = load(argv[2:])

    # Write the script.
    install_dir = os.path.join(XDG_CONFIG_HOME, 'fish', 'conf.d')
    os.makedirs(install_dir, exist_ok=True)
    install_file = os.path.join(install_dir, 'virtualfish-loader.fish')
    with open(install_file, 'w') as f:
        f.write('\n'.join(lines))


def main():
    if len(argv) >= 2 and argv[1] == "install":
        install()
    else:
        # Display an error, prompting the user to either run vf install (if
        # they're using Fish) or
        this_proc = psutil.Process()
        parent = psutil.Process(this_proc.ppid())
        the_shell = parent.cmdline()[0]
        if the_shell.endswith('fish'):
            print("virtualfish is not installed. Run vf install to install it.")
        else:
            print("virtualfish isn't compatible with {}, only fish.".format(the_shell))

if __name__ == "__main__":
    main()
