require 'spec_helper'

describe Mongoid::TimeField do
  
  describe 'when persisting a document with a TimeField datatype' do
  
    it 'should be persisted normally' do
      dummy = DummyTime.new
      dummy.open = '10:00'
      dummy.save.should eq true
    end
    
    it 'should fix bad time values' do
      dummy = DummyTime.new
      dummy.open = '10:61'
      dummy.save.should eq true
      dummy.open.should eq '11:01'
    end
  end
  
  describe 'when accessing a document from the datastore with a TimeField datatype' do
    before(:each) do
      DummyTime.create(:description => "Test", :open => '12:34')
    end
    
    it 'should have a time field value that matches the TimeField value that was initially persisted' do
      dummy = DummyTime.first
      dummy.open.should eq '12:34'
    end
  end
  
  describe 'when accessing a document from the datastore with a TimeField datatype and empty value' do
    before(:each) do
      DummyTime.create(:description => "Test")
    end
    
    it 'should have a TimeField value of 0' do
      dummy = DummyTime.first
      dummy.open.should be_nil
    end
  end

  describe 'when accessing a document from the datastore with multiple TimeField datatypes' do
    before(:each) do
      DummyTime.create(description: "Test", open: '1:23', close: '2:33')
    end
    
    it 'should have correct TimeField value for field 1' do
      dummy = DummyTime.first
      dummy.open.should eq '1:23'
    end
    it 'should have correct TimeField value for field 2' do
      dummy = DummyTime.first
      dummy.close.should eq '2:33'
    end

  end
end