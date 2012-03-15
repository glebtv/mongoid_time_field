require 'money'

module Mongoid
  module TimeField
    extend ActiveSupport::Concern
    module ClassMethods
      def time_field(*columns)
        [columns].flatten.each do |name|
          attr = name.to_sym
          field attr,    type: Integer, default: 0
          define_method(name) do
            seconds = read_attribute(attr)
            if seconds.nil?
              nil
            else
              minutes = (seconds / 60).to_i
              sprintf("%2d:%2d", minutes, (seconds - 60 * minutes))
            end
          end

          define_method("#{name}=") do |value|
            if value.blank?
              write_attribute(attr, nil)
              nil
            else
              minutes, seconds = value.split(/:/)
              write_attribute(attr, seconds + minutes * 60)
              seconds
            end
          end
        end
      end
    end
  end
end
