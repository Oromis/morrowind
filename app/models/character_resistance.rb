class CharacterResistance < CharacterProperty

  def to_s
    "#{self.class.name}[#{id}]: #{points_base}+#{points_gained}+#{points_buff}"
  end

  def as_json
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
    }
  end
end