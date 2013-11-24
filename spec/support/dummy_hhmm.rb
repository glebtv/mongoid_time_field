class DummyHhmm
  include Mongoid::Document

  field :t, type: TimeField.new(format: 'HH:MM')
  validates :t, time: { less_than: 24*60*60, greater_than: 0 }
end
