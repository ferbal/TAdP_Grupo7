require 'rspec'
require_relative '../src/PatternMatcher'


describe 'Binder' do

  it 'Bind call' do
    bool =:a_variable_name.call('anything')
    expect(bool).to eq(true)
  end

  it 'Binded Pattern' do
    result = matches?(5) do
      with(:x, type(Integer)) { x + 1 }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq(6)
  end

  it 'Multiple Binded Patterns' do
    result = matches?(5) do
      with(:x, type(Module)) { x + 1 }
      with(:a) { a + 4 }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq(9)
  end

  it 'List Binded Patterns' do
    result = matches?([1, 2]) do
      with(list([:x, :y])) { x + y }
      with(:a) { a + 4 }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq(3)
  end

  it 'Combinator Binded Pattern' do
    result = matches?('Peter') do
      with(:x.and(type(String))) { x + ' te saluda' }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq('Peter te saluda')
  end

  it 'Negated Combinator Binded Pattern' do
    result = matches?('Peter') do
      with(:x.and(type(Fixnum)).not) { x + ' te saluda' }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq('Peter te saluda')
  end

  it 'Combinator Binded Pattern 2' do
    result = matches?('Peter') do
      with(type(String).and(duck(:count), :x)) { x + ' te saluda' }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq('Peter te saluda')
  end

  it 'List + Combinator Binded Pattern' do
    result = matches?([1, 2, Object.new]) do
      with(list([duck(:+).and(type(Fixnum), :x),
                 :y.or(val(4)), duck(:+).not])) { x + y }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq(3)
  end

  it 'List + Combinator de Combinators Binded Pattern' do
    result = matches?([1, 2, Object.new]) do
      with(list([duck(:+).and(duck(:push).or(type(Fixnum)), type(Object).not.or(:x)),
                 :y.or(val(4)), duck(:+).not])) { x + y }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq(3)
  end
end

describe 'matcherVal' do
  pm = PatternMatcher.new
  it 'val' do
    bool = pm.instance_eval do
      val(5).call(5)
    end
    expect(bool).to eq(true)
  end
end

describe 'matcherType' do
  pm = PatternMatcher.new

  it 'type' do
    bool = pm.instance_eval do
      type(Integer).call(5)
    end
    expect(bool).to eq(true)
  end
end

describe 'matcherList' do
  pm = PatternMatcher.new
  an_array = [1, 2, 3, 4]

  it 'Verificar casos con match_size TRUE' do
    #list(values, match_size?)
    result = pm.instance_eval do
        list([1, 2, 3, 4], true).call(an_array) #=> true
    end
    expect(result).to eq(true)

    result = pm.instance_eval do
        list([1, 2, 3], true).call(an_array) #=> false
    end
    expect(result).to eq(false)

    result = pm.instance_eval do
        list([2, 1, 3, 4], true).call(an_array) #=> false
    end
    expect(result).to eq(false)

  end

  it 'Verificar casos con Match_Size FALSE' do
    #list(values, match_size?)
    result = pm.instance_eval do
      list([1, 2, 3, 4], false).call(an_array)
    end #=> true
    expect(result).to eq(true)

    result= pm.instance_eval do
      list([1, 2, 3], false).call(an_array)#=> true
    end
    expect(result).to eq(true)

    result = pm.instance_eval do
      list([2, 1, 3, 4], false).call(an_array) #=> false
    end
    expect(result).to eq(false)

  end

  it 'Cuando no se especifica el parametro Match_Size' do

    #Si no se especifica, match_size? se considera true
    result = pm.instance_eval do
        list([1, 2, 3]).call(an_array) #=> false
    end
    expect(result).to eq(false)

  end

  it 'Combinar Matcher de variables' do

    #También pueden combinarse con el Matcher de Variables
    result = pm.instance_eval do
        list([:a, :b, :c, :d]).call(an_array) #=> true
    end
    expect(result).to eq(true)

  end

  it 'Combinar con Matcher VAL y TYPE' do

    result = pm.instance_eval do
        list([val(1), type(Integer), val(3), val(4)]).call(an_array)
    end
    expect(result).to eq(true)

  end

end

describe 'matcherDuck' do

  pm = PatternMatcher.new

  psyduck = Object.new

  def psyduck.cuack
    'psy..duck?'
  end

  def psyduck.fly
    '(headache)'
  end

  class Dragon
    def fly
      'do some flying'
    end
  end
  a_dragon = Dragon.new

  it 'creo un metodo de instancia a un objeto para testear el duck' do
    x = Object.new
    result=nil
    x.send(:define_singleton_method, :hola) { 'hola' }
    matches?(x) do
      with(duck(:hola)) { result=true }
      with(type(Object)) { result=false }
    end
    expect(result).to eq(true)
  end

  it 'cuack and fly with psyduck' do
    result = pm.instance_eval do
        duck(:cuack, :fly).call(psyduck) #=> true
    end
    expect(result).to eq(true)
  end

  it 'cuack and fly with a dragon' do
    result = pm.instance_eval do
      duck(:cuack, :fly).call(a_dragon) #=> false
    end
    expect(result).to eq(false)
  end

  it 'a dragon can fly?' do
    result = pm.instance_eval do
      duck(:fly).call(a_dragon) #=> true
    end
    expect(result).to eq(true)
  end

  it 'object to string' do
    result = pm.instance_eval do
      duck(:to_s).call(Object.new) #=> true
    end
    expect(result).to eq(true)
  end
end


describe 'combinator and' do
  pm = PatternMatcher.new
  it 'and true' do
    bool = pm.instance_eval do
      val(5).and(val(5.0)).call(5)
    end
    expect(bool).to eq(true)
  end

  it 'and false' do
    bool = pm.instance_eval do
      type(Integer).and(type(Module)).call(5)
    end
    expect(bool).to eq(false)
  end

end

describe 'combinator or' do

  pm = PatternMatcher.new

  it 'or true1' do
    bool = pm.instance_eval do
      val(5).or(val(3)).call(5)
    end
    expect(bool).to eq(true)
  end

  it 'or true2' do
    bool = pm.instance_eval do
      val(5).or(val(3)).call(3)
    end
    expect(bool).to eq(true)
  end

  it 'or false' do
    bool = pm.instance_eval do
      val(4).or(val(3)).call(5)
    end
    expect(bool).to eq(false)
  end

end

describe 'combinator not' do
  pm = PatternMatcher.new
  it 'not true' do
    bool = pm.instance_eval do
      type(String).not.call('soy un string')
    end
    expect(bool).to eq(false)
  end

  it 'not false' do
    bool = pm.instance_eval do
      type(Integer).not.call('no soy un numero')
    end
    expect(bool).to eq(true)
  end
end

describe 'Pattern matcher' do

  it 'Pattern matching' do
    result = matches?(5) do
      with(type(Module).and(val(5))) { 'aca no matchea' }
      with(type(Integer)) { 'aca matchea' }
      otherwise { 'aca no llega' }
    end
    expect(result).to eq('aca matchea')
  end

  it 'Pattern matching no matching' do
    expect{ matches?(5) do
      with(type(Module).and(val(5))) { 'aca no matchea' }
      with(type(Symbol)) { 'aca matchea' }
    end }.to raise_error(PatternMatcherException)
  end

  it 'Validar ausencia de With`s`' do
    #result='no llegue a nada'

    expect{matches?(5) do
      otherwise { result='aca no llega' }
      #with(type(Integer)) { result='aca matchea' }
    end}.to raise_error(PatternMatcherException)
  end

  it 'Validar With´s posteriores al Otherwise`' do
    result='no llegue a nada'
    expect{matches?(5) do
      with(type(Module).and(val(5))) { result = 'aca no matchea' }
      with(type(Integer)) { result='aca matchea' }
      otherwise { result='aca no llega' }
      with(type(Integer)) { result='aca matchea' }
    end}.to raise_error(PatternMatcherException)
  end

  it 'Validar multiples Otherwise`' do
    result='no llegue a nada'
    expect{matches?(5) do
      with(type(Module).and(val(5))) { result = 'aca no matchea' }
      with(type(Integer)) { result='aca matchea' }
      otherwise { result='aca no llega' }
      otherwise { result='aca no llega' }
    end}.to raise_error(PatternMatcherException)
  end

end

=begin
describe 'combinator and' do

  it 'and true' do
    pm = PatternMatcher.new
    bool = pm.instance_eval do
      val(4).or(val(3)).call(5)
    end
    expect(bool).to eq(false)
  end
end
=end