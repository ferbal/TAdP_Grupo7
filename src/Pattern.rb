
class Pattern
  attr_accessor :matchers, :an_object, :proc_asociado

  def initialize(&block)
    @proc_asociado= block
  end

  def call
    self.matchers.each { |matcher|
      if matcher.binder
        self.singleton_class.send(:attr_accessor, matcher.symbol)
        self.singleton_class.send("#{matcher.symbol}=".to_sym,matcher.objeto_Bindeado)
      end}
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

end

class PatternOtherwise < Pattern

  def matches
    true
  end

end