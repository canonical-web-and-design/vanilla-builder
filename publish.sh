#!/usr/bin/env bash

set -ex

source lib/helpers.sh

# Settings
export FRAMEWORK_DIR=`pwd`/framework
export HOMEPAGE_DIR=`pwd`/homepage
export LIB_DIR=`pwd`/lib
export ASSETS_URL=https://162.213.32.143/v1/

prepare_directories git@github.com:ubuntudesign/vanilla-framework.git
increment_version_number ${RELEASE_LEVEL}
add_version_tag
npm_publish
compile_css
upload_css
update_docs
update_project_homepage
