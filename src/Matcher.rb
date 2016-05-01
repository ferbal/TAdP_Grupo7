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

 class Matcher

   attr_accessor :mproc, :vars

   def initialize(&block)
     @mproc= block
     @vars= []
   end

   def call(obj)
     @mproc.call obj
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
           flag= self.bind_and_call(e, list1[i])
         else
           flag = e.equal? list1[i]
         end
       end
       i = i+1
     end

     return flag
   end

   #combinators
   def and(*matchers)
     matchers<< self
     m= Matcher.new {|n| matchers.all?{|matcher| m.bind_and_call(matcher, n)}}

   end

   def or(*matchers)
     matchers<< self
     m=Matcher.new {|n| matchers.any?{|matcher| m.bind_and_call(matcher, n)}}
   end

   def not
     m=Matcher.new{|n| !m.bind_and_call(self, n)}
   end

   def bind_and_call(matcher, obj)
     result = matcher.call(obj)
     if matcher.is_a? Symbol
       self.vars.push(matcher)
       self.define_singleton_method(matcher){obj}
     elsif !matcher.vars.empty?
       matcher.vars.each{|var| self.define_singleton_method(var){matcher.send(var)}}
       self.vars.push(*matcher.vars)
     end
     result
   end

  def bind_with(obj, pattern_matcher)
    @vars.each {|e| m=self.send(e)
    pattern_matcher.define_singleton_method(e){m}}
  end
end
