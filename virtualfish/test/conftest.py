import pytest
from .repl import Fish
from ..loader import load
from os import mkdir, path


@pytest.fixture
def f():
    return Fish()


@pytest.fixture
def vf(f):
    mkdir(path.join(f.homedir, ".virtualenvs"))
    f.run("\n".join(load()))
    return f


@pytest.fixture
def vf_active(vf):
    vf.run("vf new myenv")
    vf.run("vf activate myenv")
    return vf
