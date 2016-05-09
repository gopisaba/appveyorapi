# AppVeyor Cookbook

This cookbook
- Installs the [AppVeyor deployment agent](https://www.appveyor.com/docs/deployment/agent#installing-appveyor-deployment-agent)
- [Triggers a deployment](https://www.appveyor.com/docs/api/environments-deployments#start-deployment) from the Appveyor API

## Requirements
### Chef
- Chef 12.6

## Recipes
### Default
Installs the required gems. `include_recipe` the default, to ensure the required gems are installed on the chef-client

## Resources
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

```ruby
appveyor_agent '3.12.0' do
  environment_access_key '1234abcd890432kj'
  deployment_group 'test'
end
```
