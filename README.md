# appveyorapi Cookbook

[![Build status](https://ci.appveyor.com/api/projects/status/pjsvg21lu5knixg6?svg=true)]
(https://ci.appveyor.com/project/Gopi/appveyorapi)

Initiates the deployment in Appveyor CI tool

## Requirements
### Gems
- json
- HTTParty

### Chef
- Chef 12.5+

## Recipes
### default  
Installs the AppVeyor agent

Set the following attributes:
```
node['environment_access_key']
node['deployment_group']
```

For more examples see the test/fixtures directory

## Resources and Providers
### Agent Install
```ruby
appveyor_agent '3.12.0' do
  environment_access_key '1234abcd890432kj'
  deployment_group 'test'
end
```
#### Attributes
- `version` - Specify the Appveyor deployment agent version to be installed like `3.12.0` or say it as `latest`
- `environment_access_key` - Environment Access Key is a secure string used to pair Deployment agent. Specify the Appveyor environment access key.
- `deployment_group` - Deployment group allows matching only specific group of Deployment Agents. Specify the Appveyor deployment group name.

### Start Deployment
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
- `name` - Environment name in Appveyor(Case sensitive). It could be any Environment like Agent, FTP, Azure, etc.,
- `account` - Account which has privilege to start the deployment in Appveyor.
- `api_token` - API token for the service account in Appveyor.
- `project` - Name of the build project in the Appveyor to be deployed in the specified environment(Case sensitive).
- `buildversion` - (optional) Build version of the project to be deployed in the specified environment. If it is not specified, cookbook will deploy the last successfully deployed build version. If you specify it as `latest` then it builds latest build for that project.
