class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      name_sym = "@#{name.to_s}".to_sym

      define_method(name) do
        instance_variable_get(name_sym)
      end

      define_method("#{name.to_s}=".to_sym) do |arg|
        instance_variable_set(name_sym, arg)
      end
    end

  end
end
