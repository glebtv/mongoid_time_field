class DummyV2
  include Mongoid::Document

  field :description

  field :open, type: TimeField.new(format: "hh:MM")
  field :close, type: TimeField.new(format: 'hh:MM')

  field :worktime, type: TimeField.new(format: 'HH:MM')
  field :time_of_day, type: TimeField.new(format: 'HH:MM:SS')
  field :duration, type: TimeField.new(format: 'mm:SS')
end
