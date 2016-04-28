Symbol.send(:define_method, :call) do
|obj|
  true
end

#Variante 1 (sin clase Matcher, pero tiene que modificar Proc)
begin
  def val(obj)
    Proc.new { |n| n == obj }
  end

  def type(obj)
    Proc.new { |n| n.is_a?(obj) }
  end

  #combinators
  Proc.send(:define_method, :and) do
  |block|
    Proc.new { |n| block.call(n) and self.to_proc.call(n) }
  end

  Proc.send(:define_method, :or) do
  |block|
    Proc.new { |n| block.call(n) or self.to_proc.call(n) }
  end

  Proc.send(:define_method, :not) do
    Proc.new { |n| !self.to_proc.call(n) }
  end
end

# #Variante 2 (con clase Matcher)
#
# def val(obj)
#   Matcher.new {|n| n == obj}
#  end
#
# def type(obj)
#    Matcher.new{|n| n.is_a?(obj)}
# end
#
#  class Matcher
#
#    attr_accessor :mproc
#
#    def initialize(&block)
#      @mproc= block
#    end
#
#    def call(obj)
#      @mproc.call obj
#    end
#
#    #combinators
#    def and(matcher)
#      Matcher.new {|n| matcher.call(n) and self.call(n)}
#    end
#
#    def or(matcher)
#      Matcher.new{|n| matcher.call(n) or self.call(n)}
#    end
#
#    def not
#      Matcher.new{|n| !self.call(n)}
#    end
#    def binder
#      false
#    end
#
#  end
