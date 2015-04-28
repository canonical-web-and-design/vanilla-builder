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

    git clone ${git_url} ${dir_path} || (
        git -C ${dir_path} fetch origin \
        && git -C ${dir_path} reset --hard origin/${branch}
    )
}

function prepare_directories {
    # Prepare the three directories for the build
    # prepare_directories ${framework_repository} ${uploader_repository}

    framework_repository=$1
    uploader_repository=$2

    update_git_dir ${FRAMEWORK_DIR} ${framework_repository} master
    update_git_dir ${HOMEPAGE_DIR} ${framework_repository} gh-pages
}

function increment_npm_version {
    release_level=$1

    cd ${FRAMEWORK_DIR}
    ${LIB_DIR}/bump_package_version.py ${release_level}
    cd -
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
    echo "Not implemented"
    exit 1
    
    # Install node stuff
    npm install 2> /dev/null

    # Compile CSS and docs
    node_modules/gulp/bin/gulp.js build
}

function upload_css {
    echo "Not implemented"
    exit 1

    # Upload CSS to the assets server
    export ASSETS_SERVER_URL=https://assets.staging.ubuntu.com/v1/
    export ASSETS_SERVER_TOKEN=$(cat ~/.assets-server.token)
    upload-asset build/css/ubuntu-styles.css --url-path guidelines-version-${VERSION}.css --tags "jenkins.ubuntu.qa guidelines"
    upload-asset build/css/ubuntu-styles.min.css --url-path guidelines-version-${VERSION}.min.css --tags "jenkins.ubuntu.qa guidelines"
}

function update_docs {
    echo "Not implemented"
    exit 1

    rm -rf gh-pages/docs
    mv master/build/docs gh-pages/docs
    git -C gh-pages add .
    git -C gh-pages commit -m "jenkins.ubuntu.com: Auto-generate docs for release v${VERSION}"
    git -C gh-pages push origin gh-pages
}

function update_project_homepage {
    echo "Not implemented"
    exit 1
}
