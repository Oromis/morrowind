module PdfHelper
  # Constants
  PADDING = 2
  COLOR_HP = 'FFCC99'
  COLOR_STA = 'CCFF99'
  COLOR_MAGICKA = 'D7F9FD'

  COLOR_FIRE = 'FF9999'
  COLOR_FROST = '66CCFF'
  COLOR_POISON = '99FF99'
  COLOR_SHOCK = 'FFFFCC'
  COLOR_DISEASE = 'FFCCCC'

  COLOR_GOOD = '006100'
  COLOR_BAD = '9C0006'

  SIZE_TINY = 9
  SIZE_SMALL = 12

  HEADING_CELL_HEIGHT = 18
  CELL_HEIGHT = 18

  FORMULA_FORMAT = { styles: [:italic], size: PdfHelper::SIZE_SMALL }

  # Table styling
  def heading_table(table)
    table.cells.overflow = :shrink_to_fit
    table.cells.align = :center
    table.cells.height = HEADING_CELL_HEIGHT
    table.cells.padding = PADDING
    table.row(0).borders = []
    table.row(1).font_style = :bold
  end

  def invisible_table(table)
    table.cells.border_width = 0
    table.cells.align = :center
    table.cells.padding = PADDING * 2
    table.row(0).font_style = :bold
  end

  def counter_box(table)
    heading_table table
    table.row(1).padding = [11, 0, 0]
    table.row(1).size = 6.mm
    table.row(1).font_style = :normal
    table.row(1).height = 15.mm
    table.row(1).border_width = 2
    table.row(1).valign = :top
  end

  def value_table(table)
    table.cells.align = :center
    table.cells.padding = PADDING
    table.cells.height = CELL_HEIGHT
    table.cells.overflow = :shrink_to_fit
    table.row(0).borders = []
  end

  def info_table(table)
    value_table table
    table.width = 230
    table.row(0).font_style = :bold
  end

  def property_table(table)
    value_table table
    table.width = 230
    table.row(0).font_style = :bold
    table.column(-3).align = :left
    table.column(-2..-1).border_width = 2
    table.column(-2..-1).width = 20.mm
  end

  def skill_table(table, skills, colored_attributes)
    property_table table
    if colored_attributes
      table.column(0).width = 10
      skills.each_with_index  do |skill, index|
        color = skill.property.attr.color
        table.column(0).row(index + 1).style.background_color = color ? color[1..-1] : nil
      end
    end
  end

  def table_2d(table)
    table.cells.border_width = 2
    value_table table
    table.cells.padding = [PADDING, PADDING + 1]
    table.column(0).border_width = 0
    table.column(0).align = :right
  end

  def annotation_style(cells)
    cells.border_width = 0
    cells.background_color = nil
    cells.height = 12
    cells.size = PdfHelper::SIZE_TINY
    cells.font_style = :italic
  end

  def h_table(table)
    table.cells.padding = [PdfHelper::PADDING, PdfHelper::PADDING + 1]
    table.column(0).border_width = 0
    table.column(0).align = :right
    table.column(0).padding = [PdfHelper::PADDING + 1, PdfHelper::PADDING + 2, PdfHelper::PADDING + 1, 0]
    table.column(1).align = :center
    table.column(1).border_width = 2
    table.column(2).align = :left
    table.column(2).padding = [PdfHelper::PADDING + 1, 0, PdfHelper::PADDING + 1, PdfHelper::PADDING + 2]
    annotation_style table.column(2)
  end

  def list_table(table)
    value_table table
  end

  # Formatters
  def format_modifier(val)
    '|' * val
  end

  def format_dec(val)
    number_with_precision val, precision: 2, strip_insignificant_zeros: true
  end

  def format_perc(perc, options = {})
    if perc.nil? || (perc == 0 && options[:empty_if_zero])
      ' '
    else
      perc.floor.to_s + '%'
    end
  end

  def format_armor_slot(slot, key, char, formula = nil)
    [
        slot.item&.name,
        case slot.item&.armor_type
          when 'light_armor' then 'Leicht'
          when 'medium_armor' then 'Mittel'
          when 'heavy_armor' then 'Schwer'
          else 'Ohne'
        end,
        char.armor_skill(key).floor,
        case key
          when :chest then 0.3
          when :shoulders then 0.2
          else 0.1
        end,
        char.slot_map[key].item&.armor || 0,
        format_dec(char.send(formula || "armor_#{key.to_s}"))
    ]
  end

  def format_combat_skill(skill, char)
    [
        skill.property.name,
        skill.battle_points.floor,
        skill.points_offensive.floor,
        skill.points_defensive.floor,
        skill.attack.floor + RuleSet.encumberance_factor(:attack) * char.encumberance,
        skill.parry.floor + RuleSet.encumberance_factor(:parry) * char.encumberance,
        [
            skill.property.attack_prop_1&.abbr&.upcase,
            skill.property.attack_prop_2&.abbr&.upcase,
            skill.property.attack_prop_3&.abbr&.upcase
        ].select { |a| not a.nil? }.join('+'),
        [
            skill.property.parry_prop_1&.abbr&.upcase,
            skill.property.parry_prop_2&.abbr&.upcase,
            skill.property.parry_prop_3&.abbr&.upcase
        ].select { |a| not a.nil? }.join('+'),
    ]
  end

  def format_weapon_slot(slot)
    [
        slot.item&.name,
        slot.item&.speed,
        slot.item&.min_damage,
        slot.item&.d6_damage,
        format_perc(slot.item&.condition),
    ]
  end

  def format_school_of_magic(skill, char)
    [
        map_school_name(skill.property.name),
        skill.property.check1&.name,
        (char.property_points(skill.property.check1) * RuleSet.check_target_factor).floor,
        skill.property.check2&.name,
        (char.property_points(skill.property.check2) * RuleSet.check_target_factor).floor,
        skill.property.name,
        (char.property_points(skill.property) * RuleSet.check_target_factor).floor,
        (char.property_points(skill.property) * RuleSet.check_target_factor).floor,
    ]
  end

  def format_spell(spell, char)
    [
        [spell.name, spell.desc].compact.join(': '),
        spell.school.name,
        spell.mana_cost,
        format_dec(spell.range_in_m),
        [spell.min_effect&.floor, spell.max_effect&.floor].compact.join('-'),
        spell.effect(char.property_points spell.school),
        (spell.handicap != 0 ? spell.handicap : ''),
    ]
  end

  def format_item(item, char)
    text = item.name
    unless item.desc.blank?
      text = "#{text} - #{item.desc}".truncate(100)
    end
    [
        text,
        item.quantity,
        format_dec(item.weight),
        format_dec(item.total_weight),
    ]
  end

  def render_bottom_origin(text, options)
    box = Prawn::Text::Formatted::Box.new(text, { at: [0, 200], **options })
    box.render(dry_run: true)
    box = Prawn::Text::Formatted::Box.new(text, { at: [0, box.height], **options })
    box.render
  end

  def color_column
    @use_colored_attributes ? [''] : []
  end

  private

  def map_school_name(name)
    if name == 'Redekunst'
      'Gesang'
    else
      name
    end
  end
end