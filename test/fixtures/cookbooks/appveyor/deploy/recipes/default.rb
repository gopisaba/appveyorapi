# http://www.appveyor.com/downloads/deployment-agent/latest/AppveyorDeploymentAgent.msi

appveyor_agent 'latest' do
  access_key node['environment_access_key']
  deployment_group 'web'
end

appveyor_deploy '1.0.269' do
  api_token node['api_token']
  environment_name 'psm-archive-production'
  project_slug '8174'
  account_name 'js-devops'
end
