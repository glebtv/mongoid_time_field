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
  describe 'iso8601' do
    it 'hh:mm' do
      dummy = DummyV2.new
      dummy.open = '10:00'
      dummy.open.iso8601.should eq 'PT10H'
    end
    it 'seconds' do
      dummy = DummyV2.new
      dummy.open = '10:10'
      dummy.open.iso8601.should eq 'PT10H10M'
    end
    it 'hh:mm' do
      dummy = DummyV2.new
      dummy.def = '10:00'
      dummy.def.iso8601.should eq 'PT10M'
    end
    it 'seconds' do
      dummy = DummyV2.new
      dummy.def = '10:10'
      dummy.def.iso8601.should eq 'PT10M10S'
    end
    it 'date' do
      dummy = DummyV2.new
      dummy.open = '12000:00'
      dummy.open.iso8601.should eq 'P1Y4M13DT8H'
    end
    it 'date' do
      dummy = DummyV2.new
      dummy.def = '120:00:00'
      dummy.def.iso8601.should eq 'P5D'
    end
  end
  describe 'datatype' do
    it 'is persisted normally' do
      dummy = DummyV2.new
      dummy.open = '10:00'
      dummy.save.should eq true
    end

    it '#to_i' do
      dummy = DummyV2.new
      dummy.open = '2:00'
      dummy.open.to_i.should eq 7200
    end
   
    it 'set as int minutes in HH:MM' do
      dummy = DummyV2.new
      dummy.open = '120'
      dummy.open.to_i.should eq 7200
      dummy.open.should eq '2:00'
    end

    it 'allows querying' do
      DummyV2.create!(open: '10:00')
      second = DummyV2.create!(open: '10:05')
      last = DummyV2.create!(open: '11:00')
      DummyV2.where(open: {'$gt' => 10 * 3600 + 5 * 60 }).count.should eq 1
      DummyV2.where(open: {'$gt' => '10:05'}).count.should eq 1
      DummyV2.where(open: '10:05').first.id.should eq second.id
      DummyV2.where(open: '11:00').first.id.should eq last.id
      DummyV2.where(open: last.open).first.id.should eq last.id
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

  describe 'formats' do
    it 'works with HH:MM' do
      dummy = DummyV2.new
      dummy.worktime = '1:00'
      dummy.save.should eq true
      dummy.worktime.should eq '01:00'
    end

    it 'works with HH:MM:SS' do
      dummy = DummyV2.new
      dummy.time_of_day = '1:00'
      dummy.save.should eq true
      dummy.time_of_day.should eq '00:01:00'
      dummy.time_of_day.seconds.should eq 60
      dummy.time_of_day.minutes.should eq 1
    end

    it 'works with mm:SS' do
      dummy = DummyV2.new
      dummy.duration = '1:00'
      dummy.save.should eq true
      dummy.duration.should eq '1:00'
      dummy.duration.seconds.should eq 60
      dummy.duration.minutes.should eq 1
    end

    it 'mm:SS handles more minutes' do
      dummy = DummyV2.new
      dummy.duration = '120:00'
      dummy.save.should eq true
      dummy.duration.should eq '120:00'
      dummy.duration.seconds.should eq (120 * 60)
      dummy.duration.minutes.should eq 120
    end

    it 'HH:MM handles more hours' do
      dummy = DummyV2.new
      dummy.worktime = '121:00'
      dummy.save.should eq true
      dummy.worktime.should eq '121:00'
    end

    it 'HH:MM:SS handles more hours' do
      dummy = DummyV2.new
      dummy.time_of_day = '120:00:00'
      dummy.save.should eq true
      dummy.time_of_day.should eq '120:00:00'
      dummy.time_of_day.minutes.should eq (120 * 60)
    end

    it 'HH:MM:SS normalizes' do
      dummy = DummyV2.new
      dummy.time_of_day = '1:70:00'
      dummy.save.should eq true
      dummy.time_of_day.should eq '02:10:00'
      dummy.time_of_day.minutes.should eq (130)
    end
  end

  describe 'optional hours' do
    it 'parses hours' do
      dummy = DummyV2.new
      dummy.def = '1:02:03'
      dummy.def.should eq '1:02:03'
    end

    it 'formats without hours when no hours are present' do
      dummy = DummyV2.new
      dummy.def = '02:03'
      dummy.def.should eq '2:03'
    end
   
    it '#to_i' do
      dummy = DummyV2.new
      dummy.def = '2:00'
      dummy.def.to_i.should eq 120
    end
   
    it 'set as int minutes in HH:MM' do
      dummy = DummyV2.new
      dummy.def= '120'
      dummy.def.to_i.should eq 120
      dummy.def.should eq '2:00'
    end
  end

  describe 'another separator' do
    it 'parses hours' do
      dummy = DummyV2.new
      dummy.sep = '1-02-03'
      dummy.sep.should eq '1-02-03'
    end

    it 'formats without hours when no hours are present' do
      dummy = DummyV2.new
      dummy.sep = '02-03'
      dummy.sep.should eq '2-03'
    end
   
    it '#to_i' do
      dummy = DummyV2.new
      dummy.sep = '2-00'
      dummy.sep.to_i.should eq 120
    end
   
    it 'set as int minutes in HH:MM' do
      dummy = DummyV2.new
      dummy.sep = '120'
      dummy.sep.to_i.should eq 120
      dummy.sep.should eq '2-00'
    end
  end

  describe 'validation' do
    it 'validates presence' do
      dummy = DummyValidate.new
      dummy.should_not be_valid
      dummy.errors.count.should eq 1
      dummy.errors.messages[:def][0].should eq "can't be blank"
      dummy.save.should eq false
    end

    it 'validates numericality' do
      dummy = DummyValidate.new
      dummy.should_not be_valid
      dummy.errors.count.should eq 1
      dummy.errors.messages[:def][0].should eq "can't be blank"
      dummy.def = '10:00'
      dummy.should be_valid
      dummy.errors.count.should eq 0
      dummy.save.should eq true
    end
  end

  describe 'HH:MM' do
    it 'stores properly' do
      h = DummyHhmm.create!(t: '12:30')
      h.t.should eq '12:30'
      h.t.to_s.should eq '12:30'
      h.t.to_i.should eq ( (12 * 60) + 30) * 60
      h.reload
      h.t.should eq '12:30'
      h.t.to_s.should eq '12:30'
      h.t.to_i.should eq ( (12 * 60) + 30) * 60
    end

    it 'validates' do
      h = DummyHhmm.new(t: '24:30')
      h.valid?.should be_false
      h = DummyHhmm.new(t: '23:30')
      h.valid?.should be_true
    end
  end

  describe 'Value' do
    it 'does compare' do
      opt = {format: 'mm:SS'}
      Mongoid::TimeField::Value.new(120, opt).to_s.should eq '2:00'
      (Mongoid::TimeField::Value.new(120, opt) > Mongoid::TimeField::Value.new(119, opt)).should be_true
    end

  end
end
