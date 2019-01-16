# The actual PDF
prawn_document do |pdf|
  char = @character

  pdf.font_families.update("Planewalker" => {
      :normal => Rails.root.join("app/assets/fonts/planewalker-webfont.ttf").to_s
  })

  # -----------------------------------------------------------------------------------------------------
  # First page: Cover sheet
  # -----------------------------------------------------------------------------------------------------

  pdf.image Rails.root.join('app/assets/images/logo.png'), position: :right, width: 30

  pdf.move_down 55.mm
  pdf.font 'Planewalker', size: 36 do
    pdf.text "Morrowind PnP", align: :center
  end

  pdf.move_down 20.mm
  pdf.font_size 20 do
    pdf.text "Character Sheet", align: :center
  end

  pdf.move_down 5.mm
  pdf.text "Version #{char.rule_set.version}", align: :center

  pdf.move_down 50.mm
  pdf.font 'Planewalker', size: 36 do
    pdf.text char.name, align: :center
  end

  render_bottom_origin(
      [{ text: DateTime.now.strftime("%d.%m.%Y") }],
      width: pdf.bounds.width, valign: :bottom, align: :right, document: pdf
  )

  render_bottom_origin(
      [
        { text: "Creator\n", styles: [:bold] },
        { text: "Arian Lorenz\n\n" },
        { text: "Programmer\n", styles: [:bold] },
        { text: "David Bauske" },
      ],
      width: pdf.bounds.width, valign: :bottom, align: :left, document: pdf
  )

  # -----------------------------------------------------------------------------------------------------
  # New Page: Basic Info, attributes, skills
  # -----------------------------------------------------------------------------------------------------

  pdf.start_new_page

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
    table.column(1..2).width = 40.mm
  end

  pdf.move_down 5.mm

  # Abilities
  pdf.float do
    char.race.abilities.each do |ability|
      pdf.table([[ability.name], [ability.desc]],
          position: 30.mm,
          width: 50.mm, &method(:invisible_table)
      )
    end
  end
  pdf.float do
    char.birthsign.abilities.each do |ability|
      pdf.table([[ability.name], [ability.desc]],
          position: 80.mm,
          width: 50.mm, &method(:invisible_table)
      )
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
    other_skills = char.skills
              .select { |skill| skill.skill_type == 'other' }
              .sort { |a, b| a.order <=> b.order }
    pdf.table([[*color_column, 'Andere Skills', 'Wert', 'Modi.'],
        *other_skills
             .map { |skill| [*color_column, skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
    ],
        position: :right
    ) do |table|
      skill_table table, other_skills, @use_colored_attributes
    end
  end

  # Attributes
  pdf.table([[*color_column, 'Attribut', 'Wert', 'Modi.'],
      *char.character_attributes.map { |attr| [*color_column, attr.property.name, attr.points.floor, format_modifier(attr.multiplier)] }]
  ) do |table|
    property_table table
    if @use_colored_attributes
      table.column(0).width = 10
      char.character_attributes.each_with_index  do |attr, index|
        table.column(0).row(index + 1).style.background_color = attr.property.color ? attr.property.color[1..-1] : nil
      end
    end
  end

  # Major skills
  pdf.move_down 5.mm
  major_skills = char.skills
            .select { |skill| skill.skill_type == 'major' }
            .sort { |a, b| a.order <=> b.order }
  pdf.table([[*color_column, 'Hauptskill', 'Wert', 'Modi.'],
      *major_skills
           .map { |skill| [*color_column, skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
  ]) do |table|
    skill_table table, major_skills, @use_colored_attributes
  end

  # Minor skills
  pdf.move_down 5.mm
  minor_skills = char.skills
            .select { |skill| skill.skill_type == 'minor' }
            .sort { |a, b| a.order <=> b.order }
  pdf.table([[*color_column, 'Nebenskill', 'Wert', 'Modi.'],
      *minor_skills
           .map { |skill| [*color_column, skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
  ]) do |table|
    skill_table table, minor_skills, @use_colored_attributes
  end

  # LvL-up
  pdf.move_down 5.mm
  pdf.table([
      ['LvL-Up: Modis', 'Attributspunkte'],
      [0, 1],
      ['1-4', 2],
      ['5-7', 3],
      ['8-9', 4],
      ['10+', 5],
  ], &method(:info_table))

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
          '< 21', '1 BEH',
          { content: '', colspan: 2 },
          '< 90', '1 BEH',
          { content: '', colspan: 3 },
          '-1 BEH',
          '-3 BEH',
      ],
      [
          '< 11', '3 BEH',
          { content: '', colspan: 2 },
          '< 50', '3 BEH',
      ],
      [
          '< 6', '6 BEH',
          { content: '', colspan: 2 },
          '< 20', '6 BEH',
      ],
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
    annotation_style table.row(3..5)
  end

  pdf.move_down 2.mm

  # Initiative, wounds, encumbrance
  pdf.float do
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
  pdf.move_down 6.mm
  slots = char.slot_map
  pdf.table([
      %w(\  Rüstungsteil Rüstart Skill Faktor Wert Eff.Wert \ ),
      ['Kürass', *format_armor_slot(slots[:chest], :chest, char), { content: 'Effektivwert: Skill / 30 * Faktor * Wert', rowspan: 7 }],
      ['Kopf', *format_armor_slot(slots[:head], :head, char)],
      ['Schulter', *format_armor_slot(slots[:shoulders], :shoulders, char)],
      ['Beine', *format_armor_slot(slots[:legs], :legs, char)],
      ['Stiefel', *format_armor_slot(slots[:feet], :feet, char)],
      ['Stulpen', *format_armor_slot(slots[:arms], :arms, char)],
      ['Schild', *format_armor_slot(slots[:shield_hand], :shield_hand, char, 'armor_shield')],
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
      format_weapon_slot(slots[:left_hand]),
      [''] * 5,
  ], column_widths: [col_width * 3, col_width, col_width * 0.6, col_width * 0.6, col_width, col_width * 2]) do |table|
    value_table table
    table.column(0).align = :left
    table.rows(1..-1).border_width = 2
  end

  # -----------------------------------------------------------------------------------------------------
  # New Page: Magic
  # -----------------------------------------------------------------------------------------------------

  pdf.start_new_page

  # Magic & chanting checks
  pdf.table([
      ['Magie & Gesang', 'Probe 1', '', 'Probe 2', '', 'Probe 3', '', 'Ausgleich'],
      *char.skills
           .select { |s| s.property.school_of_magic? }
           .sort { |a,b| a.property.order <=> b.property.order }
           .map { |skill| format_school_of_magic skill, char },
      [{ content: '', colspan: 7 }, 'skill / 5 - 2 BEH'],
  ], column_widths: [col_width * 2, *([col_width * 2, col_width * 0.5] * 3), col_width * 1.5]) do |table|
    table_2d table
    table.row(0).column(0).font_style = :bold
    check_labels = table.column(1..5).filter { |c| [1, 3, 5].include? c.column }
    check_labels.align = :left
    check_labels.border_width = 1
    annotation_style table.rows(-1)
  end

  # Spell book
  spell_table_widths = { 1 => 25.mm, 2 => 9.mm, 3 => 9.mm, 4 => 14.mm, 5 => 9.mm, 6 => 9.mm }
  spell_table_cols = 7
  pdf.table([
      ['Spruch / Lied', 'Schule',
          { image: Rails.root.join('app/assets/images/mana.png'), image_height: 14, image_width: 14, position: :center },
          { image: Rails.root.join('app/assets/images/range.png'), image_height: 14, image_width: 14, position: :center },
          { image: Rails.root.join('app/assets/images/magic.png'), image_height: 14, image_width: 14, position: :center },
          'Atm',
          { image: Rails.root.join('app/assets/images/handicap.png'), image_height: 14, image_width: 14, position: :center },
      ],
      *char.spells
           .group_by { |spell| spell.school.id }
           .map { |_,spells| spells }
           .sort { |a,b| a.first.school.order <=> b.first.school.order }
           .map { |entry| entry.map { |spell| format_spell spell, char } << ([''] * spell_table_cols) }
           .flatten(1)
  ],
      column_widths: spell_table_widths,
      width: pdf.bounds.width,
      header: true
  ) do |table|
    list_table table
    table.column(0).align = :left
    non_empty_handicap = table.column(6).filter { |cell| !cell.content.blank? }
    non_empty_handicap.filter { |cell| cell.content.to_f > 0 }.text_color = PdfHelper::COLOR_BAD
    non_empty_handicap.filter { |cell| cell.content.to_f < 0 }.text_color = PdfHelper::COLOR_GOOD
  end

  # Fill the remaining space on the page with a blank table
  pdf.move_down -PdfHelper::CELL_HEIGHT
  remaining_cells = (pdf.cursor / PdfHelper::CELL_HEIGHT).floor
  if remaining_cells > 0
    pdf.table(
        remaining_cells.times.map { [''] * spell_table_cols },
        column_widths: spell_table_widths,
        width: pdf.bounds.width,
        &method(:list_table)
    )
  end

  # -----------------------------------------------------------------------------------------------------
  # New Page: Inventory
  # -----------------------------------------------------------------------------------------------------

  grouped_items = char.items.group_by(&:container)
  item_table_cols = 4
  item_table_widths = { 1 => col_width, 2 => col_width, 3 => col_width }

  Item.containers.each do |container|
    pdf.start_new_page

    pdf.float do
      key = "#{container[0]}_weight"
      pdf.table([[ 'Gewicht', char.respond_to?(key) ? char.send(key).to_f : nil ]], position: :center) do |table|
        h_table table
        table.columns(1).width = col_width * 1.5
      end
    end

    pdf.float do
      key = "max_#{container[0]}_weight"
      desc = "#{RuleSet.container_factor container[0]} * #{RuleSet.container_abbr(container[0]).upcase}"
      pdf.table([[ 'Max', char.respond_to?(key) ? char.send(key) : nil, desc]], position: :right) do |table|
        h_table table
        table.columns(1).width = col_width * 1.5
      end
    end

    pdf.table([[ I18n.t("activerecord.attributes.item.container.#{container[0]}") ]]) do |table |
      h_table table
      table.cells.font_style = :bold
    end

    pdf.move_down 5.mm

    pdf.table([
        %w(Gegenstand Anz Gew Ges),
        *(grouped_items[container[0]] || [])
             .group_by(&:type)
             .map { |_,items| items }
             .map { |items| items.sort { |a,b| a.index <=> b.index } }
             .map { |entry| entry.map { |item| format_item item, char } << ([''] * item_table_cols) }
             .flatten(1)
    ],
        column_widths: item_table_widths,
        width: pdf.bounds.width,
        header: true
    ) do |table|
      list_table table
      table.column(0).align = :left
      table.row(0).font_style = :bold
    end

    # Fill the remaining space on the page with a blank table
    pdf.move_down -PdfHelper::CELL_HEIGHT
    remaining_cells = (pdf.cursor / PdfHelper::CELL_HEIGHT).floor
    if remaining_cells > 0
      pdf.table(
          remaining_cells.times.map { [''] * item_table_cols },
          column_widths: item_table_widths,
          width: pdf.bounds.width,
          &method(:list_table)
      )
    end
  end
end
