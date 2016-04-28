require 'rspec'
require_relative '../src/Matcher.rb'

describe 'matcher' do

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

