require "mongoid_time_field/version"
require "mongoid_time_field/time_field"

module Mongoid
  module TimeField
    extend ActiveSupport::Concern
    autoload :ClassMethods, 'mongoid_time_field/class_methods'
    autoload :Value,        'mongoid_time_field/value'
  end
end
