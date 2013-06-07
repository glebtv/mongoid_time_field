class DummyV2
  include Mongoid::Document

  field :description

  field :open, type: TimeField.new(format: "hh:MM")
  field :close, type: TimeField.new(format: 'hh:MM')
end
