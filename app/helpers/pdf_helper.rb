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

  SIZE_SMALL = 10

  # Table styling
  def heading_table(table)
    table.cells.align = :center
    table.cells.padding = PADDING
    table.row(0).borders = []
    table.row(1).font_style = :bold
  end

  def counter_box(table)
    heading_table table
    table.row(1).padding = [11, 10, 0]
    table.row(1).size = 6.mm
    table.row(1).font_style = :normal
    table.row(1).height = 15.mm
    table.row(1).border_width = 2
    table.row(1).valign = :top
  end

  def value_table(table)
    table.cells.align = :center
    table.cells.padding = PADDING
    table.row(0).borders = []
  end

  def property_table(table)
    value_table table
    table.width = 220
    table.row(0).font_style = :bold
    table.column(0).align = :left
    table.column(1..-1).border_width = 2
    table.column(1..-1).width = 20.mm
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
    cells.size = PdfHelper::SIZE_SMALL
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

  # Formatters
  def format_modifier(val)
    '|' * val
  end

  def format_dec(val)
    '%0.2f' % val
  end

  def format_perc(perc)
    perc.floor.to_s + '%'
  end

  def format_armor_slot(slot, key, char)
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
        char.armor_value(key).floor,
        format_dec(char.send("armor_#{key.to_s}"))
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
    ]
  end
end