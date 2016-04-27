class Matcher

  def val(value)
    return Proc.new {|n| n == value }
  end

  def type(klass)
    return Proc.new {|n| n.class == klass}
  end

  def list(list, *match_size)

    raise "Exceso de Parametros" if match_size.count>1

    match_size[0] = true if match_size.empty?

    return Proc.new do |n|
      (match_size.first == true && n.count == list.count && compare_array_elements(n,list)) || match_size.first == false && compare_array_elements(n,list)
    end


  end

  def compare_array_elements(list1, list2)
    flag = true
    i = 0

    list2.each do |e|

      if flag then
        flag = e.equal? list1[i]
      end
      i = i+1
    end

    return flag
  end

end
