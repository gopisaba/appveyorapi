# # Cookbook Name:: appveyor-agent
# # Resource:: deploy
# #
# # Copyright (C) 2016 J Sainsburys PLC
# #
# # Licensed under the Apache License, Version 2.0 (the "License");
# # you may not use this file except in compliance with the License.
# # You may obtain a copy of the License at
# #
# #     http://www.apache.org/licenses/LICENSE-2.0
# #
# # Unless required by applicable law or agreed to in writing, software
# # distributed under the License is distributed on an "AS IS" BASIS,
# # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# # See the License for the specific language governing permissions and
# # limitations under the License.
# #
#

resource_name :appveyor_deploy
property :environment_name, String, required: true
property :project_slug, String, required: true # Find this from project URL
property :account_name, String, required: true
property :build_version, String, name_property: true
property :api_token, String, required: true
property :project_slug, String, required: true
property :build_job_id, String
property :environment_variables, Hash, required: true

action :create do
  require 'HTTParty'
  require 'json'

  def deploy_json
    body = {
      environmentName: environment_name,
      accountName: account_name,
      projectSlug: project_slug,
      buildVersion: build_version
    }
    parsed = JSON.parse(body)
    parsed['environmentName'] = environment_by_name
    parsed['accountName'] = account
    parsed['projectSlug'] = project_by_name
    parsed['buildVersion'] = if buildversion.nil?
                               build_latest_version
                             else
                               build_by_version
                             end
    parsed
  end

  def start_deploy
    json = deploy_json
    response = HTTParty.post('https://ci.appveyor.com/api/deployments',
                             body: json.to_json,
                             headers: { 'Authorization' => "Bearer #{api_token}",
                                        'Content-Type' => 'application/json',
                                        'Accept' => 'application/json' })
    response.code
  end

  def build_by_version
    response = HTTParty.get("https://ci.appveyor.com/api/projects/#{account}/#{project}/build/#{buildversion}",
                            headers: { 'Authorization' => "Bearer #{api_token}" })
    if response.code == 200
      return response['build']['version']
    else
      raise "Build number #{buildversion} not found"
    end
  end

  def build_latest_version
    response = HTTParty.get("https://ci.appveyor.com/api/projects/#{account}/#{project}",
                            headers: { 'Authorization' => "Bearer #{api_token}" })
    begin
      request.inspect
    rescue
      puts "Unable to find the latest Build number for the project #{project}"
    end
    response['build']['version']
  end

  def project_by_name(name)
    projects = HTTParty.get('https://ci.appveyor.com/api/projects',
                            headers: { 'Authorization' => "Bearer #{api_token}" })
    projects.each do |project|
      response = project['name']
    end
  end

  def environment_by_name
    environments = HTTParty.get('https://ci.appveyor.com/api/environments',
                                headers: { 'Authorization' => "Bearer #{api_token}" })
    response = false
    environments.each do |env|
      response = env['name'] == name ? true : false
    end
    if response == true
      return name
    else
      raise "Unable to find the environment #{name}"
    end
  end
end
