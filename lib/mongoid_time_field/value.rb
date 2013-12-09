module Mongoid::TimeField
  class Value
    YEARS_FACTOR = ((365 * 303 + 366 * 97) / 400) * 86400
    MONTHS_FACTOR = (((365 * 303 + 366 * 97) / 400) * 86400) / 12

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

    def format
      @options[:format].dup
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

    # source: https://github.com/arnau/ISO8601/blob/master/lib/iso8601/duration.rb (MIT)
    def iso8601
      duration = @seconds
      sign = '-' if (duration < 0)
      duration = duration.abs
      years, y_mod = (duration / YEARS_FACTOR).to_i, (duration % YEARS_FACTOR)
      months, m_mod = (y_mod / MONTHS_FACTOR).to_i, (y_mod % MONTHS_FACTOR)
      days, d_mod = (m_mod / 86400).to_i, (m_mod % 86400)
      hours, h_mod = (d_mod / 3600).to_i, (d_mod % 3600)
      minutes, mi_mod = (h_mod / 60).to_i, (h_mod % 60)
      seconds = mi_mod.div(1) == mi_mod ? mi_mod.to_i : mi_mod.to_f # Coerce to Integer when needed (`PT1S` instead of `PT1.0S`)

      seconds = (seconds != 0 or (years == 0 and months == 0 and days == 0 and hours == 0 and minutes == 0)) ? "#{seconds}S" : ""
      minutes = (minutes != 0) ? "#{minutes}M" : ""
      hours = (hours != 0) ? "#{hours}H" : ""
      days = (days != 0) ? "#{days}D" : ""
      months = (months != 0) ? "#{months}M" : ""
      years = (years != 0) ? "#{years}Y" : ""

      date = %[#{sign}P#{years}#{months}#{days}]
      time = (hours != "" or minutes != "" or seconds != "") ? %[T#{hours}#{minutes}#{seconds}] : ""
      date + time
    end

    def minutes
      @seconds / 60
    end

    def mongoize
      @seconds
    end

    def inspect
      '"' + to_s + '"'
    end

    def >(x)
      raise ArgumentError, 'Argument is not Mongoid::TimeField::Value' unless x.is_a? Mongoid::TimeField::Value
      @seconds > x.seconds
    end

    def <(x)
      raise ArgumentError, 'Argument is not Mongoid::TimeField::Value' unless x.is_a? Mongoid::TimeField::Value
      @seconds < x.seconds
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
