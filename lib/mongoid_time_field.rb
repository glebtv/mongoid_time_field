require "mongoid_time_field/version"
require "mongoid_time_field/time_field"

module Mongoid
  module TimeField
    extend ActiveSupport::Concern
    autoload :ClassMethods, 'mongoid_time_field/class_methods'
    autoload :Value,        'mongoid_time_field/value'
  end
end

if Object.const_defined?("TimeValidator")
  puts "[WARN] Mongoid Time Field: TimeValidator is already defined, not loading ours"
else
  require "mongoid_time_field/validator"
end

if Object.const_defined?("RailsAdmin")
  require "mongoid_time_field/rails_admin"
end
