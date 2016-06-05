resource_name :appveyor_deploy

property :name, name_attribute: true, kind_of: String, required: true
property :api_token, kind_of: String, required: true
property :account, kind_of: String, required: true
property :project, kind_of: String, required: true
property :buildversion, kind_of: String

$projectsapi = 'https://ci.appveyor.com/api/projects'
$environmentsapi = 'https://ci.appveyor.com/api/environments'
$deploymentsapi = 'https://ci.appveyor.com/api/deployments'

action_class do
  require 'httparty'
  require 'json'
  def load_json
    body = '{
        "environmentName": "environmentName",
        "accountName": "serviceAccount",
        "projectSlug": "projectName",
        "buildVersion": "1.0.11"
    }'
    parsed = JSON.parse(body)
    parsed['environmentName'] = get_environment_by_name
    parsed['accountName'] = account
    parsed['projectSlug'] = get_project_by_name
    parsed['buildVersion'] = if buildversion.nil?
                               get_build_by_deployments
                             elsif buildversion == 'latest'
                               get_build_latest_version
                             else
                               get_build_by_version
                             end
    return parsed
  end

  def start_deploy
    json = load_json
    response = HTTParty.post(
                 $deploymentsapi,
                 body: json.to_json,
                 headers: {
                   'Authorization' => "Bearer #{api_token}",
                   'Content-Type' => 'application/json',
                   'Accept' => 'application/json' },
                 debug_output: $stdout)
    return response.code
  end

  def get_build_by_version
    response = HTTParty.get(
                 "#{$projectsapi}/#{account}/#{project}/build/#{buildversion}",
                 headers: { 'Authorization' => "Bearer #{api_token}" })
    if response.code == 200
      return response['build']['version']
    else
      raise "Build number #{buildversion} not found"
    end
  end

  def get_build_latest_version
    response = HTTParty.get(
                 "#{$projectsapi}/#{account}/#{project}",
                 headers: { 'Authorization' => "Bearer #{api_token}" })
    if response.code == 200
      return response['build']['version']
    else
      raise "Unable to find the latest Build number for the project #{project}"
    end
  end

  def get_project_by_name
    projects = HTTParty.get(
                 $projectsapi,
                 headers: { 'Authorization' => "Bearer #{api_token}" })
    response = false
    projects.each do |proj|
      response = proj['name'] == project ? true : false
    end
    if response == true
      return project
    else
      raise "Unable to find the project #{project}"
    end
  end

  def get_environment_by_name
    environments = HTTParty.get(
                     $environmentsapi,
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

  def get_build_by_deployments
    environments = HTTParty.get(
                     $environmentsapi,
                     headers: { 'Authorization' => "Bearer #{api_token}" }) if get_environment_by_name
    environments.each do |env|
      @envdepid = env['deploymentEnvironmentId']
    end
    envdeployments = HTTParty.get(
                       "#{$environmentsapi}/#{@envdepid}/deployments",
                       headers: { 'Authorization' => "Bearer #{api_token}" })
    envdeployments['deployments'].each do |d|
      if d['deployment']['build']['status'] == 'success'
        return buildnumber = d['deployment']['build']['version']
        exit
      end
    end
  end

end

action :start do
  if start_deploy == 200
    Chef::Log.info "Converged successfully"
  else
    Chef::Log.error "Failed to converge"
  end
end
