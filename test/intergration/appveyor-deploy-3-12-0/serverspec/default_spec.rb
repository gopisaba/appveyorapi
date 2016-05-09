require_relative '../../../shared/spec_helper.rb'

# #  We should put a file on disk
# describe file('C:/appveyor/projects') do
#   it { should be_directory }
# end

# describe iis_website('Default Website') do
#   it{ should exist }
# end
#
# describe iis_website('Default Website') do
#   it{ should be_enabled }
# end

# describe service('IIS') do
#   it { should be_enabled }
# end

describe file('C:\\Program Files (x86)\\AppVeyor\\DeploymentAgent\\Appveyor.DeploymentAgent.Service.exe') do
  it {should_exist}
end
