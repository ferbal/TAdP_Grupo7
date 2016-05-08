class Symbol
  def call(obj)
    true
  end

  def bind_with(obj, pattern_matcher)
    pattern_matcher.define_singleton_method(self){obj}
  end

  def and(*matchers)
    matchers.push self
    matcher = matchers.shift
    matcher.and(*matchers)
  end

  def or(*matchers)
    matchers.push self
    matcher = matchers.shift
    matcher.or(*matchers)
  end

  def not
    false
  end
end

class Object

  def matches?(obj, &block)
    m = PatternMatcher.new obj
    m.instance_eval &block
    if m.has_matched
      m.result
    else
      raise PatternMatcherException, 'No matches!'
    end
  end

end