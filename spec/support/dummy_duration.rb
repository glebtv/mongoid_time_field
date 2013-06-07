class DummyDuration
  include Mongoid::Document

  field :description

  field :duration, type: TimeField.new(format: 'MM:SS')
end
