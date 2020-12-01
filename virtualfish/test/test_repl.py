import pytest

from .repl import Fish


@pytest.fixture
def f():
    return Fish()


def test_stdout(f):
    assert f.run("echo 1") == (b"1\n", b"")


def test_stderr(f):
    assert f.run("echo 1 >&2") == (b"", b"1\n")


def test_variables(f):
    f.run("set foo bar")
    assert f.run("echo $foo") == (b"bar\n", b"")


def test_return_value(f):
    with pytest.raises(ValueError):
        f.run("false")
