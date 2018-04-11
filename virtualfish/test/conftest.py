import pytest
from .repl import Fish
from ..loader import load
from os import mkdir, path

@pytest.fixture
def f():
    return Fish()


@pytest.fixture
def vf(f):
    mkdir(path.join(f.homedir, '.virtualenvs'))
    f.run('\n'.join(load()))
    return f


@pytest.fixture
def vf_active(vf):
    out, _, status = vf.run("vf new myenv")
    print(out)
    assert status == 0
    _, _, status = vf.run("vf activate myenv")
    assert status == 0
    return vf
