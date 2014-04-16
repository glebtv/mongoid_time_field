require 'rails_admin/adapters/mongoid'
require 'rails_admin/config/fields/types/text'

require 'rails_admin/adapters/mongoid'
begin
  require 'rails_admin/adapters/mongoid/property'
rescue Exception => e 
end

module RailsAdmin
  module Adapters
    module Mongoid
      class Property
        alias_method :type_without_time_field, :type
        def type
          if property.type.class.name == 'TimeField' || property.type.to_s == 'TimeField'
            :time_field
          else
            type_without_time_field
          end
        end
      end
    end
  end
end


module RailsAdmin
  module Config
    module Fields
      module Types
        class TimeField < RailsAdmin::Config::Fields::Types::String
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          register_instance_option :pretty_value do
            bindings[:object].send(name).to_s
          end

          register_instance_option :formatted_value do
            pretty_value
          end
        end
      end
    end
  end
end

