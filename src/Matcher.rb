

=begin
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
=end
 class Matcher

   attr_accessor :mproc, :vars

   def initialize(&block)
     @mproc= block
     @vars= []
   end

   def call(obj)
     @mproc.call obj
   end

   def list(list_from_parameters, match_size = true)

     @mproc= Proc.new do |list_from_proc|
       #(match_size == true && list_from_proc.count == list_from_parameters.count && compare_array_elements(list_from_proc,list_from_parameters)) || match_size == false && compare_array_elements(list_from_proc,list_from_parameters)
       result = list_from_proc.count == list_from_parameters.count && compare_array_elements(list_from_proc,list_from_parameters) if match_size
       result = compare_array_elements(list_from_proc,list_from_parameters) if !match_size
       result
     end

   end

   def compare_array_elements(list_from_proc, list_from_parameters)

     list_from_parameters.zip(list_from_proc).all? do |comparation_element|
       element_from_param = comparation_element.first
       element_from_proc = comparation_element.last
       result = bind element_from_param, element_from_proc if element_from_param.is_a? Symbol
       result = call_matcher element_from_param, element_from_proc if element_from_param.is_a? Matcher
       result = element_from_param.equal? element_from_proc unless element_from_param.is_a? Matcher or element_from_param.is_a? Symbol
       #if  element_from_param.is_a? Matcher or element_from_param.is_a? Symbol
       #    self.bind_and_call(element_from_param,element_from_proc)
       #else
       #    element_from_param.equal? element_from_proc
       #end
       result
     end
=begin
     has_match = true

     list_from_parameters.each do |element_param|

       element_index = list_from_parameters.rindex(element_param)
       element_param.equal? list_from_proc[element_index]

       value_to_bind = list_from_proc[element_index]
       is_symbol_or_matcher = (element_param.is_a? (Matcher) or element_param.is_a? Symbol)

       has_match = self.bind_and_call(element_param, value_to_bind) if (has_match and is_symbol_or_matcher)
       has_match = element_param.equal? list_from_proc[element_index] if (has_match and !is_symbol_or_matcher)

       break unless has_match

     end

     return has_match
=end
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
       #self.vars.push(matcher)
       #self.define_singleton_method(matcher){obj}
       bind(matcher,obj)
     elsif !matcher.vars.empty?
       #matcher.vars.each{|var| self.define_singleton_method(var){matcher.send(var)}}
       #self.vars.push(*matcher.vars)
       call_matcher matcher,obj
     end
     result
   end

   def bind(sym, obj)
     self.vars.push(sym)
     self.define_singleton_method(sym){obj}
   end

   def call_matcher(matcher,obj)
     matcher.vars.each{|var| self.define_singleton_method(var){matcher.send(var)}}
     self.vars.push(*matcher.vars)
   end

  def bind_with(obj, pattern_matcher)
    @vars.each {|e| m=self.send(e)
    pattern_matcher.define_singleton_method(e){m}}
  end
end
