import sys

from virtualfish.loader import load


if __name__ == "__main__":
    print(
        "⚠️  VirtualFish is installed using an old method, which might slow down "
        "shell startup. Remove the 'eval (python -m virtualfish)' line from "
        "your config.fish, then run 'vf install'.",
        file=sys.stderr,
    )
    print(";".join(load(sys.argv[1:])))
