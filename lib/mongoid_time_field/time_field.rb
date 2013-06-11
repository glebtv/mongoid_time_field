class TimeField
  def initialize(options = {})
    @options = options

    @options[:format] = 'hh?:mm:SS' unless options[:format]
    @options[:regexp] = build_regexp(options[:format]) unless options[:regexp]
  end

  def build_regexp(format)
    s = '^' + Regexp.escape(format) + '$'
    s.gsub!('hh\?', '(?<h>\d*?)')
    s.gsub!(':', ':?')
    s.gsub!('-', '-?')
    s.gsub!('_', '_?')

    s.gsub!('HH', '(?<h>\d*?)')
    s.gsub!('hh', '(?<h>\d*?)')
    s.gsub!('MM', '(?<m>\d*)')
    s.gsub!('mm', '(?<m>\d*)')
    s.gsub!('SS', '(?<s>\d*)')
    Regexp.new(s)
  end

  def parse(value)
    if value.blank?
      nil
    elsif value.to_i.to_s == value
      if @options[:format].index('SS').nil?
        Mongoid::TimeField::Value.new(value.to_i * 60, @options)
      else
        Mongoid::TimeField::Value.new(value.to_i, @options)
      end
    else
      match = @options[:regexp].match(value.strip)
      if match.nil?
        nil
      else
        seconds = 0
        names = match.names

        seconds += match['s'].to_i        if names.include?('s')
        seconds += match['m'].to_i * 60   if names.include?('m')
        seconds += match['h'].to_i * 3600 if names.include?('h')

        Mongoid::TimeField::Value.new(seconds, @options)
      end
    end
  end

  # Get the object as it was stored in the database, and instantiate
  # this custom class from it.
  def demongoize(object)
    if object.nil?
      nil
    else
      Mongoid::TimeField::Value.new(object, @options)
    end
  end

  # Takes any possible object and converts it to how it would be
  # stored in the database.
  def mongoize(object)
    case object
    when Mongoid::TimeField::Value then object.mongoize
    when String then parse(object).mongoize
    else object
    end
  end

  # Converts the object that was supplied to a criteria and converts it
  # into a database friendly form.
  def evolve(object)
    case object
    when String then parse(object).mongoize
    when Mongoid::TimeField::Value then object.mongoize
    else object
    end
  end
end
