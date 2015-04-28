#!/usr/bin/env bash

set -ex

source lib/helpers.sh

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
version=$(increment_npm_version ${RELEASE_LEVEL} | grep 'New version' | sed 's/New version[:] \(\.*\)/\1/g')
add_version_tag ${version}
npm_publish
compile_css
upload_css
update_docs
update_project_homepage
