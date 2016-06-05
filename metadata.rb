name 'appveyorapi'
maintainer 'Gopi'
maintainer_email 'tlk2gopisaba@gmail.com'
license 'all_rights'
description 'Trigger the deployment in the Appveyor CI'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.1'

supports 'ubuntu'
supports 'windows'
supports 'amazon'

gem 'json'
gem 'httparty'
