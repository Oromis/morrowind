class CharacterAttribute < CharacterProperty
  # Calculates the base value for this attribute
  # @param character [Character]
  def init(character)
    self.points_base = property.default_value

    # Handle favorite attribute bonus
    [character.fav_attribute1, character.fav_attribute2].each do |fav_attr|
      if fav_attr == self.property
        self.points_base += character.rule_set.fav_attr_bonus
      end
    end
  end

  def points_to_add
    case multiplier
      when 0 then 1
      when 1..4 then 2
      when 5..7 then 3
      when 8..9 then 4
      else 5
    end
  end

  def to_s
    "#{self.class.name}[#{id}]: #{points_base}+#{points_gained}+#{points_buff}"
  end

  def as_json(options = {})
    {
      'id' => id,
      'name' => property.name,
      'abbr' => property.abbr,
      'icon' => property.icon.exists? ? property.icon.url(:thumb) : nil,
      'points_base' => points_base,
      'points_buff' => points_buff,
      'points_gained' => points_gained,
      'points' => points,
      'order' => order,
      'multiplier' => multiplier,
      'points_to_add' => points_to_add,
    }
  end
end