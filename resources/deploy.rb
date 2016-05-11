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

resource_name :appveyor_deploy
property :environment_name, String, required: true
property :project_slug, String, required: true # Find this from project URL
property :account_name, String, required: true
property :build_version, String, name_property: true
property :api_token, String, required: true
property :project_slug, String, required: true


action :create do
  # include Chef::DSL::
  chef_gem 'httparty'

  require 'HTTParty'
  require 'json'
  require 'chef/log'

  def deploy_body
    body = {
      environmentName: environment_name,
      accountName: account_name,
      projectSlug: project_slug,
      buildVersion: build_version
    }
  end

  def start_deploy(deploy_body, api_token)
    response = HTTParty.post('https://ci.appveyor.com/api/deployments',
                             body: deploy_body.to_json,
                             headers: { 'Authorization' => "Bearer #{api_token}",
                                        'Content-Type' => 'application/json',
                                        'Accept' => 'application/json' })
    Chef::Log.info response.code
  end

  body = deploy_body()
  start_deploy(body, api_token)
end
