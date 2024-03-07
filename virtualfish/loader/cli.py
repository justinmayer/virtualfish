from sys import argv
import logging
import psutil

from virtualfish.loader import installer


log = logging.getLogger(__name__)
minimum_fish_version = "3.1.0"


class vcolors:
    NORMAL = "\033[0m"
    RED = "\033[31m"


def install():
    if "--help" in argv or "-h" in argv:
        print("Usage: vf install [<plugin> ...]")
        exit()
    installer.install(argv[2:])


def check_fish_version():
    """Display a warning if the minimum Fish version is not installed. Bail silently if
    the 'packaging' module is missing or if Fish is not installed."""
    try:
        import subprocess
        from packaging import version

        cmd = ["fish", "-N", "-c", "echo $version"]
        fish_version = subprocess.check_output(cmd).decode("utf-8").strip()
        # Remove any extraneous hyphen-suffixed bits
        fish_version = fish_version.partition("-")[0]
        if version.parse(fish_version) < version.parse(minimum_fish_version):
            log.warning(
                """{}WARNING: VirtualFish requires Fish {} or higher.
                   Current version: {}{}""".format(
                    vcolors.RED, minimum_fish_version, fish_version, vcolors.NORMAL
                )
            )
    except (ModuleNotFoundError, FileNotFoundError):
        pass


def main():
    check_fish_version()
    if len(argv) >= 2 and argv[1] == "install":
        install()
        print(
            "VirtualFish is now installed! To enable it for this session, "
            "run 'exec fish' to reload Fish."
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
            print(
                "VirtualFish isn't compatible with {}, only Fish {}+.".format(
                    the_shell, minimum_fish_version
                )
            )


if __name__ == "__main__":
    main()
