module SpellsHelper
  def format_spell_effect(spell)
    unless spell.min_effect.nil? || spell.max_effect.nil?
      if spell.min_effect == spell.max_effect
        number_to_human(spell.min_effect)
      else
        "#{number_to_human(spell.min_effect)} - #{number_to_human(spell.max_effect)}"
      end
    end
  end
end
