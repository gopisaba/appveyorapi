name 'appveyorapi'
maintainer 'Gopi'
maintainer_email 'tlk2gopisaba@gmail.com'
license 'all_rights'
description 'Trigger the deployment in the Appveyor CI'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.1.5'
source_url 'https://github.com/gopisaba/appveyorapi' if respond_to?(:source_url)
issues_url 'https://github.com/gopisaba/appveyorapi/issues' if
          respond_to?(:issues_url)

supports 'windows'

depends 'windows'

gem 'httparty'
