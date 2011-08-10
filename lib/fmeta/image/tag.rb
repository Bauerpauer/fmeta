class Fmeta::Image::Tag

  class UnknownTagFuzzyComparison < StandardError

    def initialize(comparator)
      super("Invalid comparator, only String and Regexp allowed")
    end

  end

  def self.split(key)
    key =~ /((.*):)?(.*)/
    [$2, $3] # category, key
  end

  attr_reader :category, :name, :dirty
  alias dirty? dirty

  def initialize(category, name, value)
    @category, @name, @value = category, name, value
    @previous_value = @value
    @dirty = false
  end

  def value
    @value
  end

  def value=(new_value)
    # Take no action if the tag isn't going to be changed
    return if new_value == @previous_value

    @previous_value = @value ? @value.dup : nil
    @dirty = true
    @value = new_value
  end

  def commit
    @previous_value = nil
    @dirty = false
  end

  def rollback
    @dirty = false
    @value = @previous_value
  end

  def eql?(other)
    self.category == other.category && self.name == other.name
  end

  def =~(other)
    case other
    when String
      other_category, other_name = self.class::split(other)
      if other_category && other_name
        @category == other_category && @name == other_name
      elsif other_category.nil? && other_name
        @name == other_name
      end
    else
      if other.respond_to?(:=~)
        other =~ "#{@category}:#{@name}"
      else
        raise UnknownTagFuzzyComparison.new(other)
      end
    end
  end

  def to_s
    "<Fmeta::Image::Tag #{category}:#{name}[#{value}]>"
  end

  def hash
    @hash ||= "#{@category}#{name}".hash
  end

end