def test_deactivate(vf_active):
    vf_active.run("vf deactivate")
    out, _ = vf_active.run("which python")
    assert not out.decode("utf8").startswith(f"{vf_active.homedir}/.virtualenvs/")
