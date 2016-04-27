require 'rspec'
require_relative 'C:/TAdP_Grupo7/Matcher.rb'

describe Matcher do

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
    #result = pm.list([:a, :b, :c, :d]).call(an_array) #=> true
    #expect.(result).to eq(true)
    #puts pm.val(5).call(5).to_s


  end
end