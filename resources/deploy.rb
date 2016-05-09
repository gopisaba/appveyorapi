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
# actions :start
# default_action :start
#
# attribute :name, name_attribute: true, kind_of: String, required: true
# attribute :api_token, kind_of: String, required: true
# attribute :account, kind_of: String, required: true
# attribute :project, kind_of: String, required: true
# attribute :buildversion, kind_of: String
# attribute :buildjobid, kind_of: String
# attribute :environmentvariables, kind_of: Hash
#
# attr_accessor :exists
#
# require 'HTTParty'
# require 'chef/log'
# require 'json'
#
# use_inline_resources
#
# action :start do
#   converge_by("Start deployment") do
#     if start_deploy == 200
#       Chef::Log.info "Converged successfully"
#     else
#       Chef::Log.error "Failed to converge"
#     end
#   end
# end
#
# def load_json
#   body = '{
#       "environmentName": "environmentName",
#       "accountName": "serviceAccount",
#       "projectSlug": "projectName",
#       "buildVersion": "1.0.11"
#   }'
#   parsed = JSON.parse(body)
#   parsed['environmentName'] = get_environment_by_name
#   parsed['accountName'] = new_resource.account
#   parsed['projectSlug'] = get_project_by_name
#   if new_resource.buildversion.nil?
#     parsed['buildVersion'] = get_build_latest_version
#   else
#     parsed['buildVersion'] = get_build_by_version
#   end
#   return parsed
# end
#
# def start_deploy
#   json = load_json
#   response = HTTParty.post("https://ci.appveyor.com/api/deployments",
#                           body: json.to_json,
#                           headers: { 'Authorization' => "Bearer #{new_resource.api_token}",
#                           'Content-Type' => 'application/json',
#                           'Accept' => 'application/json' },
#                           debug_output: $stdout)
#   return response.code
# end
#
# def get_build_by_version
#   response = HTTParty.get("https://ci.appveyor.com/api/projects/#{new_resource.account}/#{new_resource.project}/build/#{new_resource.buildversion}",
#                           headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
#   if response.code == 200
#     return response['build']['version']
#   else
#     raise "Build number #{new_resource.buildversion} not found"
#   end
# end
#
# def get_build_latest_version
#   response = HTTParty.get("https://ci.appveyor.com/api/projects/#{new_resource.account}/#{new_resource.project}",
#                           headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
#   if response.code == 200
#     return response['build']['version']
#   else
#     raise "Unable to find the latest Build number for the project #{new_resource.project}"
#   end
# end
#
# def get_project_by_name
#   projects = HTTParty.get('https://ci.appveyor.com/api/projects',
#                           headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
#   response = false
#   projects.each do |project|
#     response = project['name'] == new_resource.project ? true : false
#   end
#   if response == true
#     return new_resource.project
#   else
#     raise "Unable to find the project #{new_resource.project}"
#   end
# end
#
# def get_environment_by_name
#   environments = HTTParty.get('https://ci.appveyor.com/api/environments',
#                               headers: { 'Authorization' => "Bearer #{new_resource.api_token}" })
#   response = false
#   environments.each do |env|
#     response = env['name'] == new_resource.name ? true : false
#   end
#   if response == true
#     return new_resource.name
#   else
#     raise "Unable to find the environment #{new_resource.name}"
#   end
# end
