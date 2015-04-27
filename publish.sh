#!/usr/bin/env bash

set -ex

vanilla_repository=git@github.com:ubuntudesign/vanilla-framework.git
uploader_repo=git@github.com:ubuntudesign/asset-uploader.git
server_url=https://162.213.32.143/v1/

# Clone the project
git clone ${vanilla_repository} master || (
    git -C master fetch origin \
    && git -C master reset --hard origin/master
)

# Clone the uploader
git clone ${uploader_repository} uploader || (
    git -C uploader fetch origin \
    && git -C uploader reset --hard origin/master
)

# Clone homepage
git clone ${vanilla_repository} -b gh-pages gh-pages || (
    git -C gh-pages fetch origin \
    && git -C gh-pages reset --hard origin/gh-pages
)

source lib/functions.sh

cd master
increment_version_number
add_version_tag
npm_publish
compile_css
cd -

upload_css

cd docs
update_docs
publish_docs
update_project_homepage
cd -
