from .repl import Fish
import pytest

@pytest.fixture
def f():
    return Fish()

def test_stdout(f):
    assert f.run("echo 1") == (b'1\n', b'', 0)

def test_stderr(f):
    assert f.run("echo 1 >&2") == (b'', b'1\n', 0)

def test_variables(f):
    f.run("set foo bar")
    assert f.run("echo $foo") == (b'bar\n', b'', 0)

def test_return_value(f):
    assert f.run("false") == (b'', b'', 1)