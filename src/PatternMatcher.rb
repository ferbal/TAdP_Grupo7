def matches?(obj, &block)
  m = PatternMatcher.new obj
  m.instance_eval &block
  if m.has_matched
    m.result
  else
    'No match'
  end
end

class PatternMatcher

  attr_accessor :an_object, :has_matched, :result

  def initialize(obj)
    @an_object= obj
    @has_matched=false
  end

  def match(pattern)
      if !@has_matched and pattern.matches
        @result = pattern.call(self)
        @has_matched = true
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