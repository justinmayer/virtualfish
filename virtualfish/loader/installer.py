import os
import sys

from virtualfish.loader import load

XDG_CONFIG_HOME = os.getenv("XDG_CONFIG_HOME", os.path.expanduser("~/.config"))
INSTALL_DIR = os.path.join(XDG_CONFIG_HOME, "fish", "conf.d")
INSTALL_FILE = os.path.join(INSTALL_DIR, "virtualfish-loader.fish")


def install(plugins):
    # Calculate the script to write.
    lines = load(plugins)

    # Write the script.
    os.makedirs(INSTALL_DIR, exist_ok=True)
    with open(INSTALL_FILE, "w") as f:
        f.write("\n".join(lines))


def uninstall():
    os.unlink(INSTALL_FILE)


def addplugins(plugins=()):
    with open(INSTALL_FILE) as fp:
        conf = fp.readlines()
        position = -1
        for i, line in enumerate(conf):
            if "virtual.fish" in line:
                position = i
                continue
            for j, plugin in enumerate(plugins):
                if plugin + ".fish" in line:
                    plugins.pop(j)
        for i, p in enumerate(load(plugins, full_install=False)):
            conf.insert(position + 1 + i, p + "\n")
    with open(INSTALL_FILE, "w") as fp:
        fp.writelines(conf)
    print("Plugin(s) enabled. Run 'exec fish' to load for this session.")


def rmplugins(plugins=()):
    with open(INSTALL_FILE) as fp:
        conf = fp.readlines()
        for i, line in enumerate(conf):
            for j, plugin in enumerate(plugins):
                if plugin + ".fish" in line:
                    conf.pop(i)
    with open(INSTALL_FILE, "w") as fp:
        fp.writelines(conf)


if __name__ == "__main__":
    if sys.argv[1] == "uninstall":
        uninstall()
    elif sys.argv[1] == "addplugins":
        addplugins(sys.argv[2:])
    elif sys.argv[1] == "rmplugins":
        rmplugins(sys.argv[2:])
