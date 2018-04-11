def test_deactivate(vf_active):
    vf = vf_active
    _, _, status = vf.run("vf deactivate")
    assert status == 0
    out, _, _ = vf.run("which python")
    assert not out.decode('utf8').startswith("{homedir}/.virtualenvs/".format(homedir=vf.homedir))
