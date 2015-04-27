#!/usr/bin/env bash

function increment_version_number {
    echo "Not implemented"
    exit 1
    
}

function add_version_tag {
    echo "Not implemented"
    exit 1

    # Check this version doesn't exist
    if [[ "$(git tag -l v${VERSION})" != "" ]]; then
        echo "This version already exists"
        exit 1
    fi

    # Set new tag
    tag_name=v${VERSION}
    git tag -a ${tag_name} -m 'jenkins.ubuntu.qa: New release of guidelines'
    git push origin ${tag_name}
}

function npm_publish {
    echo "Not implemented"
    exit 1
    
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

function publish_docs {
    echo "Not implemented"
    exit 1

    # Publish documents
    git clone git@github.com:ubuntudesign/vanilla-framework.git project-dir
    ./bump_package_version.py {{ release_level }}
    npm publish project-dir
}

function update_project_homepage {
    echo "Not implemented"
    exit 1
}
