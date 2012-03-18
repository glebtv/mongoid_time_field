module Mongoid
  module TimeField
    extend ActiveSupport::Concern
    module ClassMethods
      def time_field(*columns)
        [columns].flatten.each do |name|
          attr = name.to_sym
          name_minutes = (name.to_s + '_minutes').to_sym

          field attr, type: Integer

          define_method(name) do
            minutes = read_attribute(attr)
            if minutes.nil?
              nil
            else
              hours = (minutes / 60).to_i
              sprintf("%d:%02d", hours, (minutes - 60 * hours))
            end
          end

          define_method("#{name}=") do |value|
            if value.blank?
              write_attribute(attr, nil)
              nil
            else
              hours, minutes = value.split(/:/)
              val = minutes.to_i + (hours.to_i * 60)
              write_attribute(attr, val)
              value
            end
          end

          define_method(name_minutes) do
            minutes = read_attribute(attr)
            if minutes.nil?
              nil
            else
              minutes
            end
          end

          define_method("#{name_minutes}=") do |value|
            if value.blank?
              write_attribute(attr, nil)
              nil
            else
              write_attribute(attr, value.to_i)
              value.to_i
            end
          end

        end
      end
    end
  end
end
