#!/usr/bin/env bash

# All script in here should make use of:
# - ${FRAMEWORK_DIR}
# - ${HOMEPAGE_DIR}
# - ${UPLOADER_DIR}
# - ${LIB_DIR}

function update_git_dir {
    # Update a git dir, either by cloning it or pulling changes down
    # Usage:
    # update_dir ${dir_path} ${git_url} ${branch}

    dir_path=$1
    git_url=$2
    branch=$3

    git clone -b ${branch} ${git_url} ${dir_path} || (
        git -C ${dir_path} fetch origin \
        && git -C ${HOMEPAGE_DIR} checkout ${branch} \
        && git -C ${dir_path} reset --hard origin/${branch}
    )
}

function prepare_directories {
    # Prepare the three directories for the build
    # prepare_directories ${framework_repository} ${uploader_repository}

    framework_repository=$1

    update_git_dir ${FRAMEWORK_DIR} ${framework_repository} master
    update_git_dir ${HOMEPAGE_DIR} ${framework_repository} gh-pages
}

function increment_npm_version {
    set -e

    release_level=$1

    cd ${FRAMEWORK_DIR}
    new_version=$(${LIB_DIR}/bump_package_version.py ${release_level} | grep 'New version' | sed 's/New version[:] \(\.*\)/\1/g')
    git commit --quiet package.json -m "Auto-incremented ${release_level} version number to ${new_version}"
    git push --quiet origin master
    cd - > /dev/null

    echo ${new_version}
}

function add_version_tag {
    version=$1

    cd ${FRAMEWORK_DIR}

    # Check this version doesn't exist
    if [[ "$(git tag -l v${version})" != "" ]]; then
        echo "This version already exists"
        exit 1
    fi

    # Set new tag
    tag_name=v${version}
    git tag -a ${tag_name} -m 'jenkins.ubuntu.qa: New release of guidelines'
    git push origin ${tag_name}

    echo "Pushed tag ${tag_name}"

    cd -
}

function npm_publish {
    cd ${FRAMEWORK_DIR}
    npm publish
    cd -
}

function compile_css {
    cd ${FRAMEWORK_DIR}

    # Install node stuff
    npm install 2> /dev/null

    # Compile CSS and docs
    node_modules/gulp/bin/gulp.js sasslint sass

    cd -
}

function upload_css {
    version=$1

    server_url=$2
    auth_token=$3

    upload_command="${LIB_DIR}/upload-asset.py --server-url ${server_url}
    --auth-token ${auth_token}"

    echo ${upload_options}

    # Upload CSS to the assets server
    ${upload_command} ${FRAMEWORK_DIR}/build/css/build.css --url-path vanilla-framework-version-${version}.css --tags "jenkins.ubuntu.qa vanilla-framework expanded-css"
    ${upload_command} ${FRAMEWORK_DIR}/build/css/build.min.css --url-path vanilla-framework-version-${version}.min.css --tags "jenkins.ubuntu.qa vanilla-framework minified-css"
}

function update_docs {
    version=$1

    cd ${FRAMEWORK_DIR}

    npm install 2> /dev/null
    node_modules/gulp/bin/gulp.js docs
    cd -

    rm -rf ${HOMEPAGE_DIR}/docs
    mv ${FRAMEWORK_DIR}/build/docs ${HOMEPAGE_DIR}/docs
    git -C ${HOMEPAGE_DIR} add .
    git -C ${HOMEPAGE_DIR} commit -m "jenkins.ubuntu.com: Auto-generate docs for release v${version}"
    git -C ${HOMEPAGE_DIR} push origin gh-pages
}

function update_project_homepage {
    echo "Not implemented"
    exit 1
}
