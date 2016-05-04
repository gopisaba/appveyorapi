require 'HTTParty'
require 'chef/log'
require 'json'

use_inline_resources

action :start do
  converge_by("Start deployment") do
    if start_deploy == 200
      Chef::Log.info "Converged successfully"
    else
      Chef::Log.error "Failed to converge"
    end
  end
end

def load_json
  body = '{
      "environmentName": "environmentName",
      "accountName": "serviceAccount",
      "projectSlug": "projectName",
      "buildVersion": "1.0.11"
  }'
  parsed = JSON.parse(body)
  parsed['environmentName'] = get_environment_by_name
  parsed['accountName'] = new_resource.account
  parsed['projectSlug'] = get_project_by_name
  if new_resource.buildversion.nil?
    parsed['buildVersion'] = get_build_latest_version
  else
    parsed['buildVersion'] = get_build_by_version
  end
  return parsed
end

def start_deploy
  json = load_json
  response = HTTParty.post("https://ci.appveyor.com/api/deployments",
                          body: json.to_json,
                          headers: { 'Authorization' => "Bearer #{new_resource.api_token}",
                          'Content-Type' => 'application/json',
                          'Accept' => 'application/json' },
                          debug_output: $stdout)
  return response.code
end

def get_build_by_version
  response = HTTParty.get("https://ci.appveyor.com/api/projects/#{new_resource.account}/#{new_resource.project}/build/#{new_resource.buildversion}",
                          headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
  if response.code == 200
    return response['build']['version']
  else
    raise "Build number #{new_resource.buildversion} not found"
  end
end

def get_build_latest_version
  response = HTTParty.get("https://ci.appveyor.com/api/projects/#{new_resource.account}/#{new_resource.project}",
                          headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
  if response.code == 200
    return response['build']['version']
  else
    raise "Unable to find the latest Build number for the project #{new_resource.project}"
  end
end

def get_project_by_name
  projects = HTTParty.get('https://ci.appveyor.com/api/projects',
                          headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
  response = false
  projects.each do |project|
    response = project['name'] == new_resource.project ? true : false
  end
  if response == true
    return new_resource.project
  else
    raise "Unable to find the project #{new_resource.project}"
  end
end

def get_environment_by_name
  environments = HTTParty.get('https://ci.appveyor.com/api/environments',
                              headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
  response = false
  environments.each do |env|
    response = env['name'] == new_resource.name ? true : false
  end
  if response == true
    return new_resource.name
  else
    raise "Unable to find the environment #{new_resource.name}"
  end
end
