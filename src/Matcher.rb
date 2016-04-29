Symbol.send(:define_method, :call) do
|obj|
  true
end

Symbol.send(:define_method, :bind_with) do
  |obj, pattern_matcher| pattern_matcher.define_singleton_method(self){obj}
end

# #Variante 1 (sin clase Matcher, pero tiene que modificar Proc)
# begin
#   def val(obj)
#     Proc.new { |n| n == obj }
#   end
#
#   def type(obj)
#     Proc.new { |n| n.is_a?(obj) }
#   end
#
#   def duck(*method_list)
#     Proc.new {
#         |instance| method_list.all? {
#         # |m| instance.class.instance_methods.include?(m)
#           |m| instance.methods.include? m
#       }
#     }
#   end
#
#
#   #combinators
#   Proc.send(:define_method, :and) do
#   |block|
#     Proc.new { |n| block.call(n) and self.to_proc.call(n) }
#   end
#
#   Proc.send(:define_method, :or) do
#   |block|
#     Proc.new { |n| block.call(n) or self.to_proc.call(n) }
#   end
#
#   Proc.send(:define_method, :not) do
#     Proc.new { |n| !self.to_proc.call(n) }
#   end
# end

#Variante 2 (con clase Matcher)

def val(obj)
  Matcher.new {|n| n == obj}
 end

def type(obj)
   Matcher.new{|n| n.is_a?(obj)}
end

def list(list, *match_size)
  m=MatcherList.new
  m.list(list, *match_size)
  return m
end

  def duck(*method_list)
    MatcherDuck.new {
        |instance| method_list.all? {
        # |m| instance.class.instance_methods.include?(m)
          |m| instance.methods.include? m
      }
    }
  end

 class Matcher

   attr_accessor :mproc, :vars

   def initialize(&block)
     @mproc= block
     @vars= []
   end

   def call(obj)
     @mproc.call obj
   end

   def bind_with(obj, pattern_matcher)
      true
   end

   def list(list, *match_size)

     raise "Exceso de Parametros" if match_size.count>1

     match_size[0] = true if match_size.empty?

     @mproc= Proc.new do |n|
       (match_size.first == true && n.count == list.count && compare_array_elements(n,list)) || match_size.first == false && compare_array_elements(n,list)
     end


   end

   def compare_array_elements(list1, list2)
     flag = true
     i = 0

     list2.each do |e|

       if flag then
         if e.is_a? (Matcher) or e.is_a? Symbol
           flag=e.call(list1[i])
            if e.is_a? Symbol
              @vars.push(e)
              self.define_singleton_method(e){list1[i]}
            end
         else
           flag = e.equal? list1[i]
         end
       end
       i = i+1
     end

     return flag
   end

   #combinators
   def and(matcher)
     Matcher.new {|n| matcher.call(n) and self.call(n)}
   end

   def or(matcher)
     Matcher.new{|n| matcher.call(n) or self.call(n)}
   end

   def not
     Matcher.new{|n| !self.call(n)}
   end

 end

class MatcherList < Matcher
  def bind_with(obj, pattern_matcher)
    @vars.each {|e| m=self.send(e)
    pattern_matcher.define_singleton_method(e){m}}
  end
end

class MatcherDuck < Matcher
  def bind_with(obj, pattern_matcher)
    true
  end
end
