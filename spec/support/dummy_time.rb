class DummyTime
  include Mongoid::Document
  include Mongoid::TimeField
  
  field :description
  
  time_field :open, :close

end