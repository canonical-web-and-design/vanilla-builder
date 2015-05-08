# Jenkins builder for the Vanilla framework

Example usage:

``` bash
release_level=point
release_description="Just an example release."
framework_repository=git@github.com:ubuntudesign/vanilla-framework.git
assets_server_url=https://assets.example.com/v1/
assets_server_token=SECRET_TOKEN
update_homepage=true
publish_to_npm=true

./publish.sh ${project_name} ${project_repository} ${release_level} "${release_description}" ${assets_server_url} ${assets_server_token} ${update_homepage} ${publish_to_npm}
```
