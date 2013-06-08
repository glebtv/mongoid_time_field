class DummyValidate
  include Mongoid::Document

  field :def, type: TimeField.new()

  validates_presence_of :def
end
