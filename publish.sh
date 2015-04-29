#!/usr/bin/env bash

set -ex

source lib/functions.sh

 # Check this version doesn't exist
if [[ -z "${RELEASE_LEVEL}" ]]; then
    echo "No RELEASE_LEVEL specified. Exiting."
    exit 1
fi

# Settings
export FRAMEWORK_DIR=`pwd`/framework
export HOMEPAGE_DIR=`pwd`/homepage
export LIB_DIR=`pwd`/lib
export ASSETS_URL=https://162.213.32.143/v1/

prepare_directories git@github.com:nottrobin/vanilla-framework.git
increment_npm_version ${RELEASE_LEVEL}
new_version=$(increment_npm_version ${RELEASE_LEVEL})
#npm_publish
add_version_tag ${new_version}
compile_css
upload_css
update_docs
update_project_homepage
