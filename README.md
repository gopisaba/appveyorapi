# appveyorapi Cookbook

Initiates the deployment in Appveyor CI tool

## Requirements
### Gems
- json
- HTTParty

### Chef
- Chef 11+

## Recipes
### Default
Installs the required gems. `include_recipe` the default, to ensure the required gems are installed on the chef-client

## Resources and Providers
### `appveyorapi_deploy`
The `appveyorapi_deploy` LWRP can be used to start the deployment for the specified environment in Appveyor CI using its API.

```ruby
appveyorapi_deploy 'project-production' do
  api_token '1234abcd890432kj'
  account 'serviceaccount'
  project 'project'
  buildversion '1.0.1'
end
```

#### Attributes
- `name` - Environment name in Appveyor. It could be any Environment like Agent, FTP, Azure, etc.,
- `account` - Account which has privilege to start the deployment in Appveyor
- `api_token` - API token for the service account in Appveyor
- `project` - Name of the build project in the Appveyor to be deployed in the specified environment
- `buildversion` - (optional) Build version of the project to be deployed in the specified environment. If it is not specified, cookbook will deploy the last successfully deployed build version. If you specify it as `latest` then it builds latest build for that project
