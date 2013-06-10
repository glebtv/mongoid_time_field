require "mongoid_time_field/version"
require "mongoid_time_field/time_field"

module Mongoid
  module TimeField
    extend ActiveSupport::Concern
    autoload :ClassMethods, 'mongoid_time_field/class_methods'
    autoload :Value,        'mongoid_time_field/value'
  end
end

if Object.const_defined?("RailsAdmin")
  require 'rails_admin/adapters/mongoid'
  require 'rails_admin/config/fields/types/text'
  module RailsAdmin
    module Adapters
      module Mongoid
        alias_method :type_lookup_without_time_field, :type_lookup
        def type_lookup(name, field)
          if field.type.class.name == 'TimeField'
            { :type => :time_field }
          else
            type_lookup_without_time_field(name, field)
          end
        end
      end
    end

    module Config
      module Fields
        module Types
          class TimeField < RailsAdmin::Config::Fields::Types::Text
            # Register field type for the type loader
            RailsAdmin::Config::Fields::Types::register(self)

            register_instance_option :formatted_value do
              bindings[:object].send(name).to_s
            end
          end
        end
      end
    end
  end

end
