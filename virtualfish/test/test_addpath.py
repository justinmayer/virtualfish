def test_addpath(vf):
    venv = f"{vf.homedir}/.virtualenvs/test"
    vf.run("vf new test")
    vf.run("vf activate test")
    vf.run(f"mkdir {venv}/testpath")
    vf.run(f"vf addpath {venv}/testpath")
    out, _ = vf.run(f"{venv}/bin/python -c 'import sys; print(sys.path)'")
    assert ".virtualenvs/test/testpath" in str(out)
