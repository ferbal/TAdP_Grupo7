def val(value)
  Proc.new {|n| n == value }
end

def type(klass)
  Proc.new {|x| x.is_a? klass}
end

def duck(*method_list)
  Proc.new {
      |instance| method_list.all? {
        # |m| instance.class.instance_methods.include?(m)
        |m| instance.methods.include? m
    }
  }
end