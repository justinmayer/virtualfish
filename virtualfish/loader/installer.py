import os, sys, errno

from xdg import XDG_CONFIG_HOME

from virtualfish.loader import load


INSTALL_DIR = os.path.join(XDG_CONFIG_HOME, 'fish', 'conf.d')
INSTALL_FILE = os.path.join(INSTALL_DIR, 'virtualfish-loader.fish')


def install(plugins):
    # Calculate the script to write.
    lines = load(plugins)

    # Wrap os.makesdirs to catch error in case directy is already created
    try:
        os.makedirs(INSTALL_DIR, exist_ok=True)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise


    with open(INSTALL_FILE, 'w') as f:
        f.write('\n'.join(lines))



def uninstall():
    os.unlink(INSTALL_FILE)


if __name__ == "__main__" and sys.argv[1] == "uninstall":
    uninstall()