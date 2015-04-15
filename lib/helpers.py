# System
import json
import sys


def update_version(release_level, filename='package.json'):
    """
    Bump the version number in a package.json.

    `release_level` should be a string, one of:
    - "major" (1.1.1 -> 2.0.0)
    - "minor" (1.1.1 -> 1.2.0)
    - "point" (1.1.1 -> 1.1.2)
    """

    component = {
        'major': 0,
        'minor': 1,
        'point': 2
    }

    if release_level not in component.keys():
        sys.exit(
            "release_level must be one of {0}".format(component.keys())
        )

    filename = 'package.json'

    with open(filename, 'r') as f:
        package = json.loads(f.read())

    old_version = package['version']

    version_list = old_version.split('.')
    level_position = component[release_level]
    current_version = version_list[level_position]

    # Bump the correct version
    version_list[level_position] = str(int(current_version) + 1)

    # Reset lower versions to zero
    for level in range(level_position + 1, len(version_list)):
        version_list[level] = '0'

    new_version = '.'.join(version_list)
    package['version'] = new_version

    with open(filename, 'w') as f:
        f.write(json.dumps(package, indent=4, sort_keys=True))

    return old_version, new_version
