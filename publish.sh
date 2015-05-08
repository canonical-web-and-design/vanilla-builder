#!/usr/bin/env bash

set -ex

source lib/functions.sh

 # Check this version doesn't exist
if [[ -z "${4}" ]]; then
    echo 'Not all options specified.'
    echo 'Usage: publish.sh ${PROJECT_NAME} ${PROJECT_REPOSITORY} ${RELEASE_LEVEL} ${RELEASE_DESCRIPTION} ${ASSETS_SERVER_URL} ${ASSETS_SERVER_TOKEN} ${UPDATE_HOMEPAGE} ${NPM_PUBLISH}'
    exit 1
fi

# Settings
project_name=$1
project_repository=$2
release_level=$3
release_description=$4
assets_server_url=$5
assets_server_token=$6
update_homepage=$7
publish_to_npm=$8

# Clone project
update_git_dir ${project_name} ${project_repository} master

update_info="$(increment_npm_version ${project_name} ${release_level})"
old_version=$(echo "${update_info}" | grep 'Old version' | sed 's/Old version[:] \(\.*\)/\1/g')
new_version=$(echo "${update_info}" | grep 'New version' | sed 's/New version[:] \(\.*\)/\1/g')

# add_version_tag ${project_name} ${new_version}
# compile_css ${project_name}
# upload_css ${project_name} ${project_name} ${new_version} ${assets_server_url} ${assets_server_token}

if [[ -n "${update_homepage}" ]] && ${update_homepage}; then
    # update_git_dir homepage ${project_repository} gh-pages
    # update_docs ${project_name} homepage ${new_version}
    update_project_homepage homepage ${old_version} ${new_version} "${release_description}"
fi

if [[ -n "${publish_to_npm}" ]] && ${publish_to_npm}; then
    npm_publish ${project_name}
fi
