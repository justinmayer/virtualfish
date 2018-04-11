from .repl import Fish
import pytest
from ..loader import load

def test_main_script(f):
    _, _, status = f.run('\n'.join(load()))
    assert status == 0
    _, _, status = f.run("functions -q vf")
    assert status == 0


def test_plugin_setup_event(f):
    f.run("""
    function report_event --on-event virtualfish_did_setup_plugins
        set -g LOAD_EVENT_FIRED 1
    end
    """)
    _, _, status = f.run('\n'.join(load()))
    assert status == 0
    out, _, _ = f.run("echo $LOAD_EVENT_FIRED")
    assert out == b'1\n'
