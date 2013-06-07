module Mongoid::TimeField
  class Value
    attr_accessor :seconds

    def initialize(seconds, options = {})
      if seconds.blank?
        @seconds = nil
      else
        @seconds = seconds
      end

      @options = options
    end

    def to_s
      @seconds.nil? ? nil : Time.at(@seconds).utc.strftime(@options[:strftime])
    end
    alias_method :to_str, :to_s

    def minutes
      @seconds / 60
    end

    def mongoize
      @seconds
    end

    def inspect
      '"' + to_s + '"'
    end

    def coerce(something)
      [self, something]
    end

    def ==(something)
      if seconds === something
        true
      elsif to_s === something
        true
      else
        false
      end
    end
  end
end
