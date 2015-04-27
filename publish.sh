#!/usr/bin/env bash

set -ex

source lib/helpers.sh

# Settings
export FRAMEWORK_DIR=framework
export HOMEPAGE_DIR=homepage
export UPLOADER_DIR=uploader
export LIB_DIR=lib
export ASSETS_URL=https://162.213.32.143/v1/

increment_version_number
prepare_directories git@github.com:ubuntudesign/vanilla-framework.git git@github.com:ubuntudesign/asset-uploader.git
add_version_tag
npm_publish
compile_css
upload_css
update_docs
update_project_homepage
