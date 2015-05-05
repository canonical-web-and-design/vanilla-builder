#!/usr/bin/env bash

set -ex

release_level=point
framework_repository=git@github.com:nottrobin/vanilla-framework.git
assets_server_url=https://assets.staging.ubuntu.com/v1/
assets_server_token=1beffd1d9c7c41fc931875d5a51ae8cb

./publish.sh ${framework_repository} ${release_level} ${assets_server_url} ${assets_server_token}
