import pytest

from ..loader import load
from .repl import Fish


@pytest.fixture
def f():
    return Fish()


def test_main_script(f):
    f.run("\n".join(load()))
    f.run("functions -q vf")


def test_plugin_setup_event(f):
    f.run(
        """
        function report_event --on-event virtualfish_did_setup_plugins
            set -g LOAD_EVENT_FIRED 1
        end
        """
    )
    f.run("\n".join(load()))
    out, _ = f.run("echo $LOAD_EVENT_FIRED")
    assert out == b"1\n"
