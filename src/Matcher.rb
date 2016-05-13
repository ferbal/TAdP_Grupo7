
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
       result = list_from_proc.count == list_from_parameters.count && compare_array_elements(list_from_proc,list_from_parameters) if match_size
       result = compare_array_elements(list_from_proc,list_from_parameters) if !match_size
       result
     end

   end

   def compare_array_elements(list_from_proc, list_from_parameters)

     list_from_parameters.zip(list_from_proc).all? do |comparation_element|
       element_from_param = comparation_element.first
       element_from_proc = comparation_element.last
       is_Matcher_or_Sym = (element_from_param.is_a? Symbol) || (element_from_param.is_a? Matcher)
       result = bind_and_call element_from_param, element_from_proc if is_Matcher_or_Sym
       result = element_from_param.equal? element_from_proc unless is_Matcher_or_Sym
       result
     end

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

     if matcher.is_a? Symbol
       result = bind_symbol(matcher,obj)
     elsif matcher.is_a? Matcher
       result = get_previous_binds matcher,obj
     end
     result
   end

   def bind_symbol(sym, obj)
     result = sym.call(obj)
     self.vars.push(sym)
     self.define_singleton_method(sym){obj}
     result
   end

   def get_previous_binds(matcher,obj)
     result = matcher.call(obj)
     if !matcher.vars.empty?
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
