import os

def test_deactivate(vf):
    out, _, status = vf.run("vf new test")
    print(out)
    assert status == 0
    _, _, status = vf.run("vf deactivate")
    assert status == 0
    _, _, status = vf.run("vf rm test")
    assert status == 0
    assert 'test' not in os.listdir(vf.homedir + '/.virtualenvs')

def test_cannot_deactivate_while_in_use(vf):
    out, _, status = vf.run("vf new test")
    print(out)
    assert status == 0
    _, _, status = vf.run("vf rm test")
    assert status == 1
    assert 'test' in os.listdir(vf.homedir + '/.virtualenvs')