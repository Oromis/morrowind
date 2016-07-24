module ItemHelper
  def prototype_accessor(*names)
    names.each do |name|
      define_method name do
        self[name] || prototype.try(name)
      end
    end
  end

  def prototype_enum_accessor(name, values)
    valuesByOrdinal = values.invert
    define_method name do
      if (mine = self[name])
        valuesByOrdinal[mine]
      else
        prototype.try(name)
      end
    end

    values.each do |label, ordinal|
      define_method label + '?' do
        send(name) == label
      end
    end
  end
end
