require 'spec_helper'

describe Mongoid::TimeField do
  describe 'compatibility with v0.1.0' do
    it 'should store minutes as seconds' do
      dummy = DummyTime.new
      dummy.open = '10:00'
      dummy.save.should eq true
      dummy.open_minutes.should eq 600

      dummy = DummyTime.first
      dummy.read_attribute(:open).should eq 600
      dummy.open_minutes.should eq 600
    end
  end

  describe 'datatype' do

    it 'is persisted normally' do
      dummy = DummyV2.new
      dummy.open = '10:00'
      dummy.save.should eq true
    end

    it 'allows querying' do
      DummyV2.create!(open: '10:00')
      second = DummyV2.create!(open: '10:05')
      last = DummyV2.create!(open: '11:00')
      DummyV2.where(open: {'$gt' => 10 * 3600 + 5 * 60 }).count.should eq 1
      DummyV2.where(open: {'$gt' => '10:05'}).count.should eq 1
      DummyV2.where(open: '10:05').first.id.should eq second.id
      DummyV2.where(open: '11:00').first.id.should eq last.id
    end

    it 'has proper inspect' do
      dummy = DummyV2.new
      dummy.open = '10:00'
      dummy.open.inspect.should eq '"10:00"'
    end

    it 'allows setting seconds' do
      dummy = DummyV2.new
      dummy.open = 20 * 60
      dummy.open.should eq '0:20'
    end

    it 'has proper comparsion and coercion for strings and integers' do
      dummy = DummyV2.new
      dummy.open = '10:00'
      (dummy.open == '10:00').should be_true
      (dummy.open == (10*60*60)).should be_true
      (dummy.open == (10*60*60 + 1)).should be_false
      ('10:00' == dummy.open).should be_true
      ((10*60*60) == dummy.open).should be_true
      ((10*60*60 + 1) == dummy.open).should be_false
    end

    it 'fixes bad time values' do
      dummy = DummyV2.new
      dummy.open = '10:61'
      dummy.save.should eq true
      dummy.open.should eq '11:01'
    end

    it 'handles blank values set as time' do
      dummy = DummyV2.new
      dummy.open = ''
      dummy.save.should eq true
      dummy.open.should be_nil
    end
  end

  describe 'loading from DB' do
    before(:each) do
      DummyV2.create(:description => "Test", :open => '12:34')
    end

    it 'has same value' do
      dummy = DummyV2.first
      dummy.open.should eq '12:34'
    end

    it 'has proper minutes and seconds' do
      dummy = DummyV2.first
      dummy.open.minutes.should eq 754
      dummy.open.seconds.should eq (754*60)
    end
  end

  describe 'empty value' do
    before(:each) do
      DummyV2.create(:description => "Test")
    end

    it 'should have a TimeField value of 0' do
      dummy = DummyV2.first
      dummy.open.should be_nil
    end
  end

  describe 'multiple' do
    before(:each) do
      DummyV2.create(description: "Test", open: '1:23', close: '2:33')
    end

    it 'should have correct TimeField value for field 1' do
      dummy = DummyV2.first
      dummy.open.should eq '1:23'
    end
    it 'should have correct TimeField value for field 2' do
      dummy = DummyV2.first
      dummy.close.should eq '2:33'
    end

  end
end
