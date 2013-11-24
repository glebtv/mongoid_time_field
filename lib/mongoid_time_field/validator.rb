class TimeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless options[:less_than].blank?
      unless value < Mongoid::TimeField::Value.new(options[:less_than], value.format)
        record.errors.add attribute, (options[:message] || "должно быть меньше #{options[:less_than]}") 
      end
    end
    unless options[:greater_than].blank?
      unless value > Mongoid::TimeField::Value.new(options[:greater_than], value.format)
        record.errors.add attribute, (options[:message] || "должно быть больше #{options[:greater_than]}") 
      end
    end
  end
end
