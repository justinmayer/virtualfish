def test_activate(vf):
    out, _, status = vf.run("vf new test")
    print(out)
    assert status == 0
    _, _, status = vf.run("vf activate test")
    assert status == 0
    out, _, _ = vf.run("which python")
    assert out == "{homedir}/.virtualenvs/test/bin/python\n".format(homedir=vf.homedir).encode('utf8')
