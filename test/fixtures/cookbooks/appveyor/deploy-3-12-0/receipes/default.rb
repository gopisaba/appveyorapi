# http://www.appveyor.com/downloads/deployment-agent/3.12.0/AppveyorDeploymentAgent.msi

appveyor_agent '3.21.0' do
  access_key node['appveyor_agent']['access_key']
  deployment_group 'test'
end
