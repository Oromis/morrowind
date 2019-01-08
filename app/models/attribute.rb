class Attribute < Property
  validates :default_value, numericality: { only_integer: true, 
                                            greater_than_or_equal_to: 0, 
                                            less_than_or_equal_to: 100 }
  validates :color, css_hex_color: true

  default_scope { order(:order, :name) }

  def as_json(options = {})
    case options[:mode]
      when :fav
        {
            'id' => id,
            'name' => name,
            'icon' => icon.exists? ? icon.url(:thumb) : nil
        }
      else
        {

        }
    end
  end
end
