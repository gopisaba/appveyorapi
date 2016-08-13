# http://www.appveyor.com/downloads/deployment-agent/latest/AppveyorDeploymentAgent.msi

include_recipe 'iis::mod_aspnet45'

appveyor_agent 'latest' do
  access_key node['appveyor']['access_key']
  deployment_group node['appveyor']['deployment_group']
end

appveyor_deploy node['appveyor']['environment_name'] do
  api_token node['appveyor']['api_token']
  project_slug node['appveyor']['project_slug']
  account node['appveyor']['account']
  buildversion node['appveyor']['buildversion']
end
