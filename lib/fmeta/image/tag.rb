class Fmeta::Image::Tag

  attr_reader :category, :name, :dirty
  alias dirty? dirty

  def initialize(category, name, value)
    @category, @name, @value = category, name, value
    @dirty = false
  end
  
  def value
    @value
  end

  def value=(new_value)
    @dirty = true
    @value = new_value
  end
  
  def eql?(other)
    self.category == other.category && self.name == other.name
  end
  
  def hash
    @hash ||= "#{@category}#{name}".hash
  end

end