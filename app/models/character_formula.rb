class CharacterFormula < CharacterProperty
  def init(character)
    self.points_base = 0
    begin
      if !character.nil? && !property.nil?
        self.points_base = character.instance_eval(self.property.formula)
        logger.info "Updated #{property.abbr} - New value: #{points_base}"
      end
    rescue => e
      logger.error "Could not Update #{property.abbr}: #{ e.message }"
      character.errors.add(:base, "Formula #{ property.name } is invalid! #{ e.message }")
    end
    self.points_base
  end

  def to_s
    "#{self.class.name}[#{id}]: #{points_base}+#{points_gained}+#{points_buff}"
  end
end