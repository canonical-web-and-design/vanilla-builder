#!/usr/bin/env bash

LIB_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

function update_git_dir {
    # Update a git dir, either by cloning it or pulling changes down
    # Usage:
    # update_dir ${dir_path} ${git_url} ${branch}

    dir_path=$1
    git_url=$2
    branch=$3

    git clone -b ${branch} ${git_url} ${dir_path} || (
        git -C ${dir_path} clean -fd
        git -C ${dir_path} remote set-url origin ${git_url}
        git -C ${dir_path} fetch origin
        git -C ${dir_path} checkout ${branch}
        git -C ${dir_path} reset --hard origin/${branch}
    )
}

function increment_npm_version {
    set -e

    project_path=$1
    release_level=$2

    cd ${project_path}
    update_info="$(${LIB_DIR}/bump_package_version.py ${release_level})"

    message="Auto-incremented ${release_level} version number
${update_info}"

    git commit --quiet package.json -m "${message}"
    git push --quiet origin master
    cd - > /dev/null

    echo "${update_info}"
}

function add_version_tag {
    project_path=$1
    version=$2

    cd ${project_path}

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
    project_path=$1

    cd ${project_path}
    npm publish
    cd -
}

function compile_css {
    project_path=$1

    cd ${project_path}

    # Install node stuff
    npm update

    # Compile CSS and docs
    node_modules/gulp/bin/gulp.js sasslint sass

    cd -
}

function upload_css {
    project_name=$1
    project_path=$2
    version=$3
    server_url=$4
    auth_token=$5

    upload_command="${LIB_DIR}/upload-asset.py --server-url ${server_url}
    --auth-token ${auth_token}"

    echo ${upload_options}

    # Upload CSS to the assets server
    ${upload_command} ${project_path}/build/css/build.css --url-path ${project_name}-version-${version}.css --tags "jenkins.ubuntu.qa vanilla-framework expanded-css"
    ${upload_command} ${project_path}/build/css/build.min.css --url-path ${project_name}-version-${version}.min.css --tags "jenkins.ubuntu.qa vanilla-framework minified-css"
}

function update_docs {
    project_path=$1
    homepage_path=$2
    version=$3

    cd ${project_path}

    npm update
    node_modules/gulp/bin/gulp.js docs
    cd -

    rm -rf ${homepage_path}/docs
    mv ${project_path}/build/docs ${homepage_path}/docs
    git -C ${homepage_path} add docs
    git -C ${homepage_path} commit -m "jenkins.ubuntu.qa: Auto-generate docs for release v${version}"
    git -C ${homepage_path} push origin gh-pages
}

function update_project_homepage {
    homepage_path=$1
    old_version=$2
    new_version=$3
    version_description=$4

    latest_release="<h3>Version ${new_version}</h3>
<p>${version_description}</p>
<p><a href=\"https://github.com/ubuntudesign/vanilla-framework/compare/v${old_version}...v${new_version}\">Changes since version ${old_version}</a></p>"

    release_section="<section class=\"row\" id=\"0.0.13\">
${latest_release}
</section>
"

    cd ${homepage_path}

    # Update includes
    echo "${latest_release}" > _includes/latest.html
    all_releases="${release_section}
$(cat _includes/all-releases.html)"
    echo "${all_releases}" > _includes/all-releases.html

    # Add comment to index.html to force refresh of github page
    regex="<!-- Latest release: [0-9.]* -->"
    if ! egrep "${regex}" index.html; then
        echo "Can't find release comment in index.html. Exiting."
        exit 1
    fi
    sed -i 's/'"${regex}"'/<!-- Latest release: '"${new_version}"' -->/' index.html

    git commit index.html _includes/latest.html _includes/all-releases.html -m "jenkins.ubuntu.qa: Auto-update release information for release v${new_version}"
    git push origin gh-pages
    cd -
}
