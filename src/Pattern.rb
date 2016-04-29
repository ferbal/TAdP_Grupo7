
class Pattern
  attr_accessor :matchers, :an_object, :proc_asociado

  def initialize(&block)
    @proc_asociado= block
  end

  def call(pattern_matcher)
    @proc_asociado.call
  end

end

class PatternWith < Pattern

  def initialize(*matcher, obj, &block)
    @matchers= *matcher
    @an_object= obj
    super &block
  end

  def matches
    @matchers.all?{ |m| m.call(@an_object) }
  end

  def call(pattern_matcher)
    @matchers.each { |matcher|
      matcher.bind_with(@an_object, pattern_matcher) }
    super

  end

end

class PatternOtherwise < Pattern

  def matches
    true
  end

end