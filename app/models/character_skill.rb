class CharacterSkill < CharacterProperty
  enum skill_type: [:other, :minor, :major]

  # Calculates the base points for this skill
  # @param character [Character]
  def init(character)
    case skill_type
      when 'major'
        self.points_base = character.rule_set.major_skill_base
      when 'minor'
        self.points_base = character.rule_set.minor_skill_base
      else # other skill
        self.points_base = character.rule_set.other_skill_base
    end

    if character.specialization == property.specialization
      self.points_base += character.rule_set.specialization_bonus
    end
  end

  def post_init(character)
    if property.weapon_skill?
      # Calculate attack and parry values
      if property.offensive?
        self.attack = character.send(property.abbr.to_s + '_attack_base') / 25.0 +
            points_offensive + character.offensive_buff - (character.encumberance * 2.0)
      end
      if property.defensive?
        self.parry = character.send(property.abbr.to_s + '_parry_base') / 25.0 +
            points_defensive + character.defensive_buff - character.encumberance
      end
    end
  end

  # @return true if this is a minor or major skill, false otherwise
  def gives_level_count?
    major? or minor?
  end

  def battle_points
    if property.both?
      points / 5.0
    else
      points / 6.0
    end
  end

  def to_s
    "#{self.class.name}[#{id}]: #{points_base}+#{points_gained}+#{points_buff}"
  end

  def points_defensive=(p)
    offensive, defensive = check_battle_points self.points_offensive, p
    points_distribution offensive, defensive
  end

  def points_offensive=(p)
    offensive, defensive = check_battle_points p, self.points_defensive
    points_distribution offensive, defensive
  end

  def points_distribution(offensive, defensive)
    write_attribute :points_offensive, offensive
    write_attribute :points_defensive, defensive
  end

  def as_json
    json = {
      'id' => id,
      'name' => property.name,
      'abbr' => property.abbr,
      'icon' => property.icon.exists? ? property.icon.url(:thumb) : nil,
      'points_base' => points_base,
      'points_buff' => points_buff,
      'points_gained' => points_gained,
      'points' => points,
      'skill_type' => skill_type,
      'order' => order,
      'multiplier' => multiplier,
      'is_school_of_magic' => property.school_of_magic,
      'weapon_skill' => property.weapon_skill?,
    }
    if property.weapon_skill?
      json['battle_points'] = battle_points
      json['skills_distributable'] = property.both?
      json['points_offensive'] = points_offensive
      json['points_defensive'] = points_defensive
      json['attack'] = attack.to_f
      json['parry'] = parry.to_f
    end
    if property.school_of_magic?
      json['check1'] = property.check1.abbr
      json['check2'] = property.check2.abbr
    end
    json
  end

  private
    def check_battle_points(offensive, defensive)
      total = battle_points.to_i

      case property.weapon_skill_mode
        when 'only_offensive'
          [battle_points.floor, 0]
        when 'only_defensive'
          [0, battle_points.floor]
        else
          max_difference = 4
          while offensive + defensive > total
            if offensive > defensive
              offensive -= 1
            else
              defensive -= 1
            end
          end
          difference = offensive - defensive
          if difference.abs > max_difference
            delta = ((difference.abs - max_difference) / 2).ceil
            if difference > 0
              offensive -= delta
              defensive += delta
            else
              offensive += delta
              defensive -= delta
            end
          end
          [offensive, defensive]
      end
    end
end