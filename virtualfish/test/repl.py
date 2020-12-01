"""Interact with a Fish REPL.
"""

import os
import sys
import subprocess
from subprocess import PIPE
from threading import Thread
import tempfile

try:
    from queue import Queue
except ImportError:
    from Queue import Queue


def write_thread(q, f):
    while True:
        data = q.get()
        f.write(data)
        f.flush()


def read_thread(f, q):
    while True:
        data = f.read(1)
        q.put(data)


def write(f):
    q = Queue()
    t = Thread(target=write_thread, args=(q, f))
    t.daemon = True
    t.start()
    return q


def read(f):
    q = Queue()
    t = Thread(target=read_thread, args=(f, q))
    t.daemon = True
    t.start()
    return q


def q_until_null(q):
    ba = bytearray()
    while True:
        c = q.get()
        if c == b"\0":
            return bytes(ba)
        ba.append(c[0])


class Fish:
    """A Fish instance running a custom REPL in a subprocess.

    Each instance of this class has its own subprocess, with its own
    state (variables, loaded functions, etc).
    """

    def __init__(self):
        homedir = tempfile.mkdtemp(prefix="vf-fish-home")
        self.homedir = homedir
        # Start Fish up with our custom REPL. We don't use the built-in
        # REPL because if we run Fish non-interactively we can't tell
        # the difference between Fish waiting for input and whatever
        # command we ran waiting for something else, and if we run it
        # in a pty we'd have to correctly handle the fish_prompt, fish
        # echoing back our input (and possibly even syntax highlighting
        # it), and so on.
        self.subp = subprocess.Popen(
            (
                subprocess.check_output(("which", "fish")).strip(),
                os.path.join(os.path.dirname(__file__), "repl.fish"),
            ),
            stdin=PIPE,
            stdout=PIPE,
            stderr=PIPE,
            env={"HOME": homedir},
        )
        # We read and write to/from stdin/out/err in threads, to prevent
        # deadlocks (see the warning in the subprocess docs).
        self.stdin_q = write(self.subp.stdin)
        self.stdout_q = read(self.subp.stdout)
        self.stderr_q = read(self.subp.stderr)

    def run(self, cmd, expected_exit_codes=(0,)):
        """Run a command on the REPL.

        The command can do anything except read from standard input
        (because there's currently no way for the test case to write
        into it) or print a null byte (since that's how the REPL signals
        that the command has finished).

        :param cmd: The command to run.
        :type cmd: str|bytes
        :param expected_exit_codes: The exit codes you expect the
            to produce.
        :type expected_exit_codes: Iterable[int]
        :return: Standard output, standard error.
        :rtype: Tuple[bytes, bytes]
        """
        if isinstance(cmd, str):
            cmd = cmd.encode("utf8")

        self.stdin_q.put(cmd)
        self.stdin_q.put(b"\0")
        output = q_until_null(self.stdout_q)
        error = q_until_null(self.stderr_q)
        status = int(q_until_null(self.stdout_q).decode("utf8"))

        if status not in expected_exit_codes:
            sys.stdout.write(str(output))
            sys.stderr.write(str(error))
            raise ValueError(
                "Expected command to exit with {}, got {}".format(
                    expected_exit_codes, status
                )
            )

        return output, error


if __name__ == "__main__":
    # If invoked directly, executes a bunch of simple test commands.
    # This is to make
    f = Fish()
    print(f.run("echo 1"))
    print(f.run("echo 1 >&2"))
    print(f.run("set foo bar"))
    print(f.run("echo $foo"))
    print(f.run("false"))
