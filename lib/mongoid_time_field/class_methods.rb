module Mongoid::TimeField
  module ClassMethods
    # @deprecated
    def time_field(*columns)
      [columns].flatten.each do |name|
        attr = name.to_sym
        name_minutes = (name.to_s + '_minutes').to_sym

        field attr, type: TimeField.new(format: 'mm:SS')

        # we treat minutes as seconds for compatibility with v0.1.0
        # TODO: Remove this later
        define_method(name_minutes) do
          v = send(attr)
          v.nil? ? nil : v.seconds
        end

        define_method("#{name_minutes}=") do |value|
          send(name.to_s + '=', Mongoid::TimeField::Value.new(value))
        end
      end
    end
  end
end
