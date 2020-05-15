from sys import argv
import psutil

from virtualfish.loader import installer


minimum_fish_version = "3.1"


def install():
    if "--help" in argv or "-h" in argv:
        print("Usage: vf install [<plugin> ...]")
        exit()
    installer.install(argv[2:])


def check_fish_version():
    """Exit and notify if minimum Fish version is not installed. Bail silently if
       'packaging' module is missing or if Fish is not installed."""
    try:
        import subprocess
        from packaging import version

        cmd = ["fish", "-c", "echo $version"]
        fish_version = subprocess.check_output(cmd).decode("utf-8").strip()
        if version.parse(fish_version) < version.parse(minimum_fish_version):
            print("VirtualFish requires Fish {} or higher. Current version: {}".format(
                minimum_fish_version, fish_version))
            exit()
    except (ModuleNotFoundError, FileNotFoundError):
        pass


def main():
    check_fish_version()
    if len(argv) >= 2 and argv[1] == "install":
        install()
        print(
            "VirtualFish is now installed! Run 'exec fish' to reload "
            "Fish, and you'll be able to use it!"
        )
    else:
        # Display an error prompting the user to run `vf install`, if they are
        # using Fish. If not, inform them that VirtualFish requires Fish shell.
        this_proc = psutil.Process()
        parent = psutil.Process(this_proc.ppid())
        the_shell = parent.cmdline()[0]
        if the_shell.endswith("fish"):
            print(
                "VirtualFish is not installed. Run 'vf install' to install "
                "it, then run 'exec fish' to restart your shell and "
                "load it."
            )
        else:
            print("VirtualFish isn't compatible with {}, only Fish {}+.".format(
                the_shell, minimum_fish_version))


if __name__ == "__main__":
    main()
