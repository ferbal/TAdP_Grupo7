require_relative '../src/Matcher'
require_relative '../src/Pattern'
require_relative '../src/OpenClasess'

class PatternMatcher

  attr_accessor :an_object, :has_matched, :result, :do_with, :do_otherwise, :test

  def initialize(obj=nil)
    @an_object= obj
    @has_matched=false
    @do_with = false
    @do_otherwise = false
    @test = true
  end

  def match(pattern)
      if !@has_matched and pattern.matches
        @result = pattern.call(self)
        @has_matched = true
      end
  end

  def with(*matcher, &block)
    #The sentence Otherwise has already been validated
    raise PatternMatcherException, 'The sentence Otherwise has already been validated' if @do_otherwise
    pattern = PatternWith.new *matcher, @an_object, &block
    match pattern
    @do_with = true
  end

  def otherwise(&block)
    #Undefined sentence With
    raise PatternMatcherException,'UndefinedWithError' if !@do_with
    #Another sentence Otherwise has already been validated
    raise PatternMatcherException,'MultipleOtherwiseError' if @do_otherwise
    pattern = PatternOtherwise.new &block
    @do_otherwise = true
    match pattern
  end

  def val(obj)
    Matcher.new {|n| n == obj}
  end

  def type(obj)
    Matcher.new{|n| n.is_a?(obj)}
  end

  def list(list, *match_size)
    m=Matcher.new
    m.list(list, *match_size)
    return m
  end

  def duck(*method_list)
    Matcher.new {
        |instance| method_list.all? {
        # |m| instance.class.instance_methods.include?(m)
          |m| instance.methods.include? m
      }
    }
  end

end

class PatternMatcherException < Exception
end
