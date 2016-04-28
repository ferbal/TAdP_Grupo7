require 'rspec'
require_relative '../src/Matcher'
require_relative '../src/Pattern'
#require_relative '../src/PatternMatcher'


describe 'Binder' do

  it 'bind' do
    bool =:a_variable_name.call('anything')
    expect(bool).to eq(true)
  end

end

=begin
describe 'matcher' do

  it 'val' do
    bool = val(5).call(5)
    expect(bool).to eq(true)
  end

  it 'type' do
    bool = type(Integer).call(5)
    expect(bool).to eq(true)
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
    s='no llegue a nada'
    matches?(5) do
      with(type(Module).and(val(5))){s = 'aca no matchea'}
      with(type(Integer)){s='aca matchea'}
      otherwise{s='aca no llega'}
    end
    expect(s).to eq('aca matchea')
  end

end
=end