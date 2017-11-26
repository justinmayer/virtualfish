from __future__ import print_function
import os
import sys
import pkg_resources


if __name__ == "__main__":
    try:
        version = pkg_resources.get_distribution('virtualfish').version
        commands = ['set -g VIRTUALFISH_VERSION {}'.format(version)]
    except pkg_resources.DistributionNotFound:
        commands = []

    base_path = os.path.dirname(os.path.abspath(__file__))
    commands += [
        'set -g VIRTUALFISH_PYTHON_EXEC {}'.format(sys.executable),
        'source {}'.format(os.path.join(base_path, 'virtual.fish')),
    ]

    for plugin in sys.argv[1:]:
        path = os.path.join(base_path, plugin + '.fish')
        if os.path.exists(path):
            commands.append('source {}'.format(path))
        else:
            print('virtualfish loader error: plugin {} does not exist!'.format(plugin), file=sys.stderr)

    commands.append('emit virtualfish_did_setup_plugins')
    print(';'.join(commands))
