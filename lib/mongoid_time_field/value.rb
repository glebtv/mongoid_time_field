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
    
    alias_method :to_i, :seconds

    def __bson_dump__(io, key)
      seconds.__bson_dump__(io, key)
    end

    def to_s
      if @seconds.nil?
        nil
      else
        format = @options[:format].dup

        fm, ss = @seconds.divmod(60)
        hh, mm = fm.divmod(60)

        if !format.match(/hh\?/).nil?
          if hh > 0
            format.gsub!('hh?', 'hh')
            format.gsub!('mm', 'MM')
          else
            format.gsub!(/hh\?[:\-_ ]?/, '')
          end
        end

        if format.match(/hh/i).nil?
          replaces  = {
            'mm' => fm,
            'MM' => fm.to_s.rjust(2, '0'),
            'SS' => ss.to_s.rjust(2, '0'),
          }
          format.gsub(/(mm|MM|SS)/) do |match|
            replaces[match]
          end
        else
          replaces  = {
            'hh' => hh,
            'HH' => hh.to_s.rjust(2, '0'),
            'mm' => mm,
            'MM' => mm.to_s.rjust(2, '0'),
            'SS' => ss.to_s.rjust(2, '0'),
          }
          format.gsub(/(hh|HH|mm|MM|SS)/) do |match|
            replaces[match]
          end
        end
      end
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
