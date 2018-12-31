# The actual PDF
prawn_document do |pdf|
  char = @character

  # -----------------------------------------------------------------------------------------------------
  # New Page: Basic Info, attributes, skills
  # -----------------------------------------------------------------------------------------------------

  # Render Level box
  pdf.float do
    pdf.table([['Level'], [char.level]], position: :right, width: 18.mm, &method(:counter_box))
    pdf.move_down 5.mm
    pdf.table([['Counter'], [format_modifier(char.level_count)]], position: :right, width: 18.mm, &method(:counter_box))
  end

  # Render Character base info
  pdf.table([%w(Name Rasse Sternzeichen Zunft),
      [char.name, char.race&.name, char.birthsign&.name, char.specialization&.name]],
      width: 135.mm,
  ) do |table|
    heading_table table
    table.column(0).width = 30.mm
    table.column(1).width = 40.mm
  end

  pdf.move_down 5.mm

  pdf.float do
    char.race.abilities.each do |ability|
      pdf.table([[ability.name], [ability.desc]],
          position: 30.mm,
          width: 40.mm,
      ) do |table|
        invisible_table table
      end
    end
  end

  pdf.table([['Favor Attr. 1'], [char.fav_attribute1&.name]],
      width: 30.mm,
      &method(:heading_table)
  )
  pdf.table([['Favor Attr. 2'], [char.fav_attribute2&.name]],
      width: 30.mm,
      &method(:heading_table)
  )

  pdf.move_down 10.mm

  # Other skills
  pdf.float do
    # Other skills
    pdf.table([%w(Andere\ Skills Wert Modi.),
        *char.skills
             .select { |skill| skill.skill_type == 'other' }
             .sort { |a, b| a.order <=> b.order }
             .map { |skill| [skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
    ],
        position: :right,
        &method(:property_table)
    )
  end

  # Attributes
  pdf.table([%w(Attribut Wert Modi.),
      *char.character_attributes.map { |attr| [attr.property.name, attr.points.floor, format_modifier(attr.multiplier)] }],
      &method(:property_table)
  )

  # Major skills
  pdf.move_down 5.mm
  pdf.table([%w(Hauptskill Wert Modi.),
      *char.skills
           .select { |skill| skill.skill_type == 'major' }
           .sort { |a, b| a.order <=> b.order }
           .map { |skill| [skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
  ],
      &method(:property_table)
  )

  # Minor skills
  pdf.move_down 5.mm
  pdf.table([%w(Nebenskills Wert Modi.),
      *char.skills
           .select { |skill| skill.skill_type == 'minor' }
           .sort { |a, b| a.order <=> b.order }
           .map { |skill| [skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
  ],
      &method(:property_table)
  )

  # -----------------------------------------------------------------------------------------------------
  # New Page: Combat
  # -----------------------------------------------------------------------------------------------------

  pdf.start_new_page

  col_count = 11
  col_width = pdf.bounds.width / col_count

  # HP, Endurance, Mana, Speed
  pdf.table([[
      { content: 'Trefferpunkte', colspan: 4 },
      { content: 'Ausdauer', colspan: 2 },
      { content: 'Magicka', colspan: 3 },
      { content: 'Laufweg [m]', colspan: 2 }
  ],
      %w(Atm. Max Reg +/Lvl Atm. Max Atm. Max Multi. #1 #2),
      [
          '',
          char.max_health.floor,
          char.hp_per_lvl.floor * 4,
          char.hp_per_lvl.floor,
          '',
          char.max_stamina.floor,
          '',
          char.max_mana.floor,
          char.mana_mult.floor,
          format_dec(char.speed + char.encumberance),
          format_dec(char.speed_2 + 3 * char.encumberance),
      ],
      [
          { content: '', colspan: 9 },
          '-1 BEH',
          '-3 BEH',
      ]
  ],
      width: pdf.bounds.width,
      column_widths: [col_width] * col_count
  ) do |table|
    table.cells.align = :center
    table.cells.padding = PdfHelper::PADDING
    table.columns(0..3).background_color = PdfHelper::COLOR_HP
    table.columns(4..5).background_color = PdfHelper::COLOR_STA
    table.columns(6..8).background_color = PdfHelper::COLOR_MAGICKA
    table.row(2).border_width = 2
    annotation_style table.row(3)
  end

  # Initiative, wounds, encumbrance
  pdf.float do
    pdf.move_down 7.mm
    pdf.table([
        ['Initiative', format_dec(char.initiative + 2 * char.encumberance), '-2 BEH'],
        ['Verwundungen', char.wounds.floor, ''],
        ['Behinderung (BEH)', char.encumberance.floor, '']
    ],
        position: :right, column_widths: { 1 => col_width, 2 => col_width }, &method(:h_table)
    )
  end

  # Resistances
  pdf.table([
      [{ content: 'Resistenzen', colspan: char.resistances.length }],
      %w(Feuer Eis Gift Blitz Krankh. Magie),
      [
          format_perc(char.r_fire, empty_if_zero: true),
          format_perc(char.r_frost, empty_if_zero: true),
          format_perc(char.r_poison, empty_if_zero: true),
          format_perc(char.r_shock, empty_if_zero: true),
          format_perc(char.r_disease, empty_if_zero: true),
          format_perc(char.r_magicka, empty_if_zero: true),
      ]
  ], column_widths: [col_width] * char.resistances.length) do |table|
    table.cells.align = :center
    table.cells.padding = PdfHelper::PADDING
    table.column(0).background_color = PdfHelper::COLOR_FIRE
    table.column(1).background_color = PdfHelper::COLOR_FROST
    table.column(2).background_color = PdfHelper::COLOR_POISON
    table.column(3).background_color = PdfHelper::COLOR_SHOCK
    table.column(4).background_color = PdfHelper::COLOR_DISEASE
    table.column(5).background_color = PdfHelper::COLOR_MAGICKA
    table.row(0).background_color = nil
    table.row(2).border_width = 2
  end

  # Armor
  pdf.move_down 2 * 7.mm
  slots = char.slot_map
  pdf.table([
      %w(\  Rüstungsteil Rüstart Skill Faktor Wert Eff.Wert \ ),
      ['Kürass', *format_armor_slot(slots[:chest], :chest, char), { content: 'Effektivwert: Skill / 30 * Faktor * Wert', rowspan: 7 }],
      ['Kopf', *format_armor_slot(slots[:head], :head, char)],
      ['Schulter', *format_armor_slot(slots[:shoulders], :shoulders, char)],
      ['Beine', *format_armor_slot(slots[:legs], :legs, char)],
      ['Stiefel', *format_armor_slot(slots[:feet], :feet, char)],
      ['Stulpen', *format_armor_slot(slots[:arms], :arms, char)],
      ['Schild', *format_armor_slot(slots[:shield_hand], :shield, char)],
      [{ content: '', colspan: 5 }, 'Ges.', char.total_armor.floor, '(ARMOR)']
  ],
      width: pdf.bounds.width,
      column_widths: {0 => col_width + 2, 2 => col_width, 3 => col_width, 4 => col_width, 5 => col_width, 6 => col_width, 7 => col_width * 1.5 }
  ) do |table|
    table_2d table
    table.column(0).padding = [PdfHelper::PADDING, PdfHelper::PADDING + 1, PdfHelper::PADDING, 0]
    table.column(1).align = :left
    table.columns(0..1).overflow = :truncate
    table.row(0).padding = [PdfHelper::PADDING, 0]
    annotation_style table.column(7)
    table.column(7).align = :left
  end

  # Incoming damage
  pdf.float do
    pdf.move_down 7.mm
    pdf.formatted_text [ {
        text: 'HP-Verlust = ceil( max( DMG / 3, DMG - ARMOR ) )',
        **PdfHelper::FORMULA_FORMAT
    } ], align: :right
  end

  # Evasion
  pdf.table([
      ['Klobigkeit (KLB)', char.clumsiness.floor, ''],
      ['Ausweichen', format_dec(char.evasion + char.clumsiness.floor), '-1 KLB']
  ], column_widths: { 1 => col_width, 2 => col_width }, &method(:h_table))

  # Combat skills
  pdf.move_down 3.mm
  pdf.table([
      %w(\  Punkte Off. Def. Attacke Parade Attacke-Attr Parade-Attr),
      *char.skills
           .select { |skill| skill.property.weapon_skill? }
           .sort { |a, b| a.order <=> b.order }
           .map { |skill| format_combat_skill skill, char },
      [{ content: '', colspan: 4 }, '-2 BEH', '-1 BEH'],
  ]) do |table|
    table_2d table
    table.columns(1..5).width = col_width
    table.columns(-2..-1).width = col_width * 1.8
    annotation_style table.row(-1)
    annotation_style table.columns(-2..-1)
  end

  # Attack / Parry formulas
  pdf.move_down 2.mm
  pdf.formatted_text [ {
      text: "Attacke = Attacke-Attr / #{(1 / RuleSet.combat_value_factor).round} + Off - #{RuleSet.encumberance_factor(:attack)} * BEH",
      **PdfHelper::FORMULA_FORMAT
  } ], align: :right
  pdf.formatted_text [ {
      text: "Parade = Parade-Attr / #{(1 / RuleSet.combat_value_factor).round} + Def - #{RuleSet.encumberance_factor(:parry)} * BEH",
      **PdfHelper::FORMULA_FORMAT
  } ], align: :right

  pdf.move_down 3.mm

  # Unarmed combat
  pdf.float do
    pdf.table([
        ['Faustkampf'],
        ['Stamina | FK / 2'],
        [char.hand_to_hand_damage_stamina.floor],
        ['Trefferp. | FK / 10'],
        [char.hand_to_hand_damage_hp.floor],
    ], position: :right, width: col_width * 2) do |table|
      value_table table
      table.rows(1..2).background_color = PdfHelper::COLOR_STA
      table.rows(3..4).background_color = PdfHelper::COLOR_HP
      table.rows(1).border_width = 0
      table.rows(2).border_width = 2
      table.rows(3).border_width = 0
      table.rows(4).border_width = 2
    end
  end

  # Equipped weapons
  pdf.table([
      %w(Waffe Tempo Fix d6 Zustand Stärke-Faktor),
      [*format_weapon_slot(slots[:right_hand]), format_dec(RuleSet.strength_factor_offset + char.str * RuleSet.strength_factor_gain)],
      [''] * 5 + [{ content: "#{RuleSet.strength_factor_offset} + STR * #{RuleSet.strength_factor_gain}", rowspan: 3 }],
      format_weapon_slot(slots[:right_hand]),
      [''] * 5,
  ], column_widths: [col_width * 3, col_width, col_width * 0.6, col_width * 0.6, col_width, col_width * 2]) do |table|
    value_table table
    table.column(0).align = :left
    table.rows(1..-1).border_width = 2
  end
end
