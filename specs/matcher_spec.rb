require 'rspec'
require_relative '../src/Matcher'
require_relative '../src/Pattern'
require_relative '../src/PatternMatcher'


describe 'Binder' do

  it 'Bind call' do
    bool =:a_variable_name.call('anything')
    expect(bool).to eq(true)
  end

  it 'Binded Pattern' do
    result='no llegue a nada'
    matches?(5) do
      with(:x, type(Integer)) { result= x + 1 }
      otherwise { result='aca no llega' }
    end
    expect(result).to eq(6)
  end

  it 'Multiple Binded Patterns' do
    result='no llegue a nada'
    matches?(5) do
      with(:x, type(Module)) { result= x + 1 }
      with(:a) { result= a + 4 }
      otherwise { result='aca no llega' }
    end
    expect(result).to eq(9)
  end

  it 'List Binded Patterns' do
    result='no llegue a nada'
    matches?([1, 2]) do
      with(list([:x, :y])) { result= x + y }
      with(:a) { result= a + 4 }
      otherwise { result='aca no llega' }
    end
    expect(result).to eq(3)
  end

  it 'Combinator Binded Pattern' do
    result='no llegue a nada'
    matches?('Peter') do
      with(:x.and(type(String))) { result = x + ' te saluda' }
      otherwise { result = 'aca no llega' }
    end
    expect(result).to eq('Peter te saluda')
  end

  it 'Negated Combinator Binded Pattern' do
    result='no llegue a nada'
    matches?('Peter') do
      with(:x.and(type(Fixnum)).not) { result = x + ' te saluda' }
      otherwise { result = 'aca no llega' }
    end
    expect(result).to eq('Peter te saluda')
  end

  it 'Combinator Binded Pattern 2' do
    result='no llegue a nada'
    matches?('Peter') do
      with(type(String).and(duck(:count), :x)) { result = x + ' te saluda' }
      otherwise { result = 'aca no llega' }
    end
    expect(result).to eq('Peter te saluda')
  end

  it 'List + Combinator Binded Pattern' do
    result = 'no llegue a nada'
    matches?([1, 2, Object.new]) do
      with(list([duck(:+).and(type(Fixnum), :x),
                 :y.or(val(4)), duck(:+).not])) { result= x + y }
      otherwise { result = 'aca no llega' }
    end
    expect(result).to eq(3)
  end

  it 'List + Combinator de Combinators Binded Pattern' do
    result = 'este test es un aberracion'
    matches?([1, 2, Object.new]) do
      with(list([duck(:+).and(duck(:push).or(type(Fixnum)), type(Object).not.or(:x)),
                 :y.or(val(4)), duck(:+).not])) { result= x + y }
      otherwise { result = 'aca no llega' }
    end
    expect(result).to eq(3)
  end



end

describe 'matcherVal' do

  it 'val' do
    bool = val(5).call(5)
    expect(bool).to eq(true)
  end
end

describe 'matcherType' do
  it 'type' do
    bool = type(Integer).call(5)
    expect(bool).to eq(true)
  end
end

describe 'matcherList' do

  it 'Matcher.List' do

    pm = Matcher.new
    an_array = [1, 2, 3, 4]

    #list(values, match_size?)
    result = pm.list([1, 2, 3, 4], true).call(an_array) #=> true
    expect(result).to eq(true)
    result= pm.list([1, 2, 3, 4], false).call(an_array) #=> true
    expect(result).to eq(true)
    result = pm.list([1, 2, 3], true).call(an_array) #=> false
    expect(result).to eq(false)
    result= pm.list([1, 2, 3], false).call(an_array) #=> true
    expect(result).to eq(true)
    result = pm.list([2, 1, 3, 4], true).call(an_array) #=> false
    expect(result).to eq(false)
    result = pm.list([2, 1, 3, 4], false).call(an_array) #=> false
    expect(result).to eq(false)
    #Si no se especifica, match_size? se considera true
    result = pm.list([1, 2, 3]).call(an_array) #=> false
    expect(result).to eq(false)
    #También pueden combinarse con el Matcher de Variables
    result = pm.list([:a, :b, :c, :d]).call(an_array) #=> true
    expect(result).to eq(true)
    result = pm.list([val(1), type(Integer), val(3), val(4)]).call(an_array)
    expect(result).to eq(true)
    #puts pm.val(5).call(5).to_s


  end
end

describe 'matcherDuck' do

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

  it 'cuack and fly' do

    result = duck(:cuack, :fly).call(psyduck) #=> true
    expect(result).to eq(true)

    result = duck(:cuack, :fly).call(a_dragon) #=> false
    expect(result).to eq(false)

    result = duck(:fly).call(a_dragon) #=> true
    expect(result).to eq(true)

  end

  it 'object to string' do

    result = duck(:to_s).call(Object.new) #=> true
    expect(result).to eq(true)

  end
end


describe 'combinator and' do

  it 'and true' do
    bool = val(5).and(val(5.0)).call(5)
    expect(bool).to eq(true)
  end

  it 'and false' do
    bool = type(Integer).and(type(Module)).call(5)
    expect(bool).to eq(false)
  end

end

describe 'combinator or' do

  it 'or true1' do
    bool = val(5).or(val(3)).call(5)
    expect(bool).to eq(true)
  end

  it 'or true2' do
    bool = val(5).or(val(3)).call(3)
    expect(bool).to eq(true)
  end

  it 'or false' do
    bool = val(4).or(val(3)).call(5)
    expect(bool).to eq(false)
  end

end

describe 'combinator not' do

  it 'not true' do
    bool = type(String).not.call('soy un string')
    expect(bool).to eq(false)
  end

  it 'not false' do
    bool = type(Integer).not.call('no soy un numero')
    expect(bool).to eq(true)
  end
end

describe 'Pattern matcher' do

  it 'Pattern matching' do
    result='no llegue a nada'
    matches?(5) do
      with(type(Module).and(val(5))) { result = 'aca no matchea' }
      with(type(Integer)) { result='aca matchea' }
      otherwise { result='aca no llega' }
    end
    expect(result).to eq('aca matchea')
  end

end
