import os


def test_deactivate(vf):
    vf.run("vf new test")
    vf.run("vf deactivate")
    vf.run("vf rm test")
    assert "test" not in os.listdir(vf.homedir + "/.virtualenvs")


def test_cannot_deactivate_while_in_use(vf):
    vf.run("vf new test")
    vf.run("vf rm test", expected_exit_codes=(1,))
    assert "test" in os.listdir(vf.homedir + "/.virtualenvs")
