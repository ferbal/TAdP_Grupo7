def matches?(obj, &block)
  m = PatternMatcher.new obj
  m.instance_eval &block
  #TODO agregar aca comportamiento para manejar la situacion donde no matchea con nada
end

class PatternMatcher

  attr_accessor :an_object, :has_matched

  def initialize(obj)
    @an_object= obj
    @has_matched=false
  end

  def match(pattern)
      if pattern.matches and !@has_matched
        pattern.call
        @has_matched= true
      end
  end

  def with(*matcher, &block)
    pattern = PatternWith.new *matcher, @an_object, &block
    match pattern
  end

  def otherwise(&block)
    pattern = PatternOtherwise.new &block
    match pattern
  end

end