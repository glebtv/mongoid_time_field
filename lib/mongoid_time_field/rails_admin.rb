require 'rails_admin/adapters/mongoid'
require 'rails_admin/config/fields/types/text'
module RailsAdmin
  module Adapters
    module Mongoid
      alias_method :type_lookup_without_time_field, :type_lookup
      def type_lookup(name, field)
        if field.type.class.name == 'TimeField' || field.type.to_s == 'TimeField'
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

