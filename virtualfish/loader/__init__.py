import logging
import os
import sys
import pkg_resources


log = logging.getLogger(__name__)


def load(plugins=(), full_install=True):
    try:
        version = pkg_resources.get_distribution("virtualfish").version
        commands = ["set -g VIRTUALFISH_VERSION {}".format(version)]
    except pkg_resources.DistributionNotFound:
        commands = []
    base_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    if full_install:
        commands += [
            "set -g VIRTUALFISH_PYTHON_EXEC {}".format(sys.executable),
            "source {}".format(os.path.join(base_path, "virtual.fish")),
        ]
    else:
        commands = []

    for plugin in plugins:
        path = os.path.join(base_path, plugin + ".fish")
        if os.path.exists(path):
            commands.append("source {}".format(path))
        else:
            log.error("Plugin does not exist: {}".format(plugin))
            sys.exit(1)

    if full_install:
        commands.append("emit virtualfish_did_setup_plugins")

    return commands
