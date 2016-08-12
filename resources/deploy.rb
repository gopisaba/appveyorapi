# Cookbook Name:: appveyorapi
# Resource:: appveyor_deploy
#
# Copyright (C) 2016 gopisaba
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

resource_name :appveyor_deploy

property :name, name_attribute: true, kind_of: String, required: true
property :api_token, kind_of: String, required: true
property :account, kind_of: String, required: true
property :project_slug, kind_of: String, required: true
property :buildversion, kind_of: String

default_action :start

action_class do
  def projectsapi
    'https://ci.appveyor.com/api/projects'
  end

  def environmentsapi
    'https://ci.appveyor.com/api/environments'
  end

  def deploymentsapi
    'https://ci.appveyor.com/api/deployments'
  end

  def start_deploy_body
    body = '{
        "environmentName": "environmentName",
        "accountName": "serviceAccount",
        "projectSlug": "projectName",
        "buildVersion": "1.0.11"
    }'
    JSON.parse(body)
  end

  def start_deploy_json
    parsed = start_deploy_body
    parsed['environmentName'] = env_by_name
    parsed['accountName'] = account
    parsed['projectSlug'] = project_by_name
    parsed['buildVersion'] = if buildversion.nil?
                               build_by_deploy
                             elsif buildversion == 'latest'
                               build_latest_version
                             else
                               build_by_version
                             end
    parsed
  end

  def resp(code)
    case code
    when 400 then return 'BadRequest'
    when 401 then return 'Unauthorized'
    when 403 then return 'Forbidden'
    when 405 then return 'MethodNotAllowed'
    else return 'UnknownError'
    end
  end

  def start_deploy
    json = start_deploy_json
    response = HTTParty.post(
      deploymentsapi,
      body: json.to_json,
      headers: {
        'Authorization' => "Bearer #{api_token}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      },
      debug_output: $stdout
    )
    response.code
  end

  def build_by_version
    response = HTTParty.get(
      "#{projectsapi}/#{account}/#{project_slug}/build/#{buildversion}",
      headers: { 'Authorization' => "Bearer #{api_token}" }
    )
    raise "Build number #{buildversion} not found" unless response.code == 200
    response['build']['version']
  end

  def build_latest_version
    response = HTTParty.get(
      "#{projectsapi}/#{account}/#{project_slug}",
      headers: { 'Authorization' => "Bearer #{api_token}" }
    )
    raise 'Unable to find the latest Build number' unless response.code == 200
    response['build']['version']
  end

  def project_by_name
    projects = HTTParty.get(
      projectsapi,
      headers: { 'Authorization' => "Bearer #{api_token}" }
    )
    response = false
    projects.each do |proj|
      response = true if proj['name'] == project_slug
    end if projects.code == 200
    raise "Unable to find the project #{project_slug}\
      - #{resp(project_slug.code)}" unless response == true
    project_slug
  end

  def env_by_name
    environments = HTTParty.get(
      environmentsapi,
      headers: { 'Authorization' => "Bearer #{api_token}" }
    )
    response = false
    environments.each do |env|
      response = true if env['name'] == name
    end if environments.code == 200
    raise "Unable to find the environment #{name}\
      - #{resp(environments.code)}" unless response == true
    name
  end

  def env_id
    environments = HTTParty.get(
      environmentsapi,
      headers: { 'Authorization' => "Bearer #{api_token}" }
    ) if env_by_name
    environments.each do |env|
      return env['deploymentEnvironmentId'] if env['name'] == name
    end if environments.code == 200
    raise "Unable to find the environment id #{name}\
      - #{resp(environments.code)}" unless environments.code == 200
  end

  def build_by_deploy
    envdeployments = HTTParty.get(
      "#{environmentsapi}/#{env_id}/deployments",
      headers: { 'Authorization' => "Bearer #{api_token}" }
    )
    envdeployments['deployments'].each do |d|
      if d['deployment']['build']['status'] == 'success'
        return d['deployment']['build']['version']
      end
    end if envdeployments.code == 200
    raise "Unable to find the environment for #{env_id}\
      - #{resp(envdeployments.code)}" unless envdeployments.code == 200
  end
end

action :start do
  chef_gem 'httparty'
  require 'httparty'
  require 'json'
  result = start_deploy
  if result == 200
    Chef::Log.info 'Converged successfully'
  else
    Chef::Log.error "Failed to converge - #{resp(result)}"
  end
end
