actions :start
default_action :start

attribute :name, name_attribute: true, kind_of: String, required: true
attribute :api_token, kind_of: String, required: true
attribute :account, kind_of: String, required: true
attribute :project, kind_of: String, required: true
attribute :buildversion, kind_of: String
attribute :buildjobid, kind_of: String
attribute :environmentvariables, kind_of: Hash

attr_accessor :exists
