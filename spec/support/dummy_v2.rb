class DummyV2
  include Mongoid::Document

  field :description

  field :def, type: TimeField.new()
  field :sep, type: TimeField.new(format: 'hh?-mm-SS')

  field :open, type: TimeField.new(format: "hh:MM")
  field :close, type: TimeField.new(format: 'hh:MM')

  field :worktime, type: TimeField.new(format: 'HH:MM')
  field :time_of_day, type: TimeField.new(format: 'HH:MM:SS')
  field :duration, type: TimeField.new(format: 'mm:SS')
end
