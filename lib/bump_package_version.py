#!/usr/bin/env python

"""
A script for increasing the version in an npm project's
package.json.
"""

# System
import argparse

# Local
from lib.helpers import update_version

parser = argparse.ArgumentParser()
parser.add_argument(
    "release_level",
    help=(
        "Which version level should be incremented? "
        "Options are: major, minor, point."
    )
)
args = parser.parse_args()
release_level = args.release_level

old_version, new_version = update_version(release_level)

print "Old version: {0}\nNew version: {1}".format(
    old_version, new_version
)
