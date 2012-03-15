module Mongoid
  module TimeField
    extend ActiveSupport::Concern
    module ClassMethods
      def time_field(*columns)
        [columns].flatten.each do |name|
          attr = name.to_sym
          field attr, type: Integer
          
          define_method(name) do
            seconds = read_attribute(attr)
            if seconds.nil?
              nil
            else
              minutes = (seconds / 60).to_i
              sprintf("%d:%02d", minutes, (seconds - 60 * minutes))
            end
          end

          define_method("#{name}=") do |value|
            if value.blank?
              write_attribute(attr, nil)
              nil
            else
              minutes, seconds = value.split(/:/)
              val = seconds.to_i + (minutes.to_i * 60)
              write_attribute(attr, val)
              value
            end
          end
        end
      end
    end
  end
end
