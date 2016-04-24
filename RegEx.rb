class RegEx
  def val(value)
    Proc.new {|n| n == value }
  end

  def type(klass)
    Proc.new {|x| x.is_a? klass}
  end
end