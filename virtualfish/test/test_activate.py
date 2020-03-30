def test_activate(vf):
    vf.run("vf new test")
    vf.run("vf activate test")
    out, _ = vf.run("which python")
    assert out == "{homedir}/.virtualenvs/test/bin/python\n".format(
        homedir=vf.homedir
    ).encode("utf8")
