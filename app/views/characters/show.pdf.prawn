# Table styling
def heading_table(table)
  table.cells.align = :center
  table.cells.padding = 2
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
  table.cells.padding = 2
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

# Formatters
def format_modifier(val)
  '|' * val
end

# The actual PDF
prawn_document do |pdf|
  pdf.stroke_axis

  # Render Level box
  pdf.float do
    pdf.table([['Level'], [@character.level]], position: :right, width: 18.mm, &method(:counter_box))
    pdf.move_down 5.mm
    pdf.table([['Counter'], [format_modifier(@character.level_count)]], position: :right, width: 18.mm, &method(:counter_box))
  end

  # Render Character base info
  pdf.table([%w(Name Rasse Sternzeichen Zunft),
             [@character.name, @character.race&.name, @character.birthsign&.name, @character.specialization&.name]],
            width: 135.mm,
            &method(:heading_table)
  )

  pdf.move_down 8.mm
  pdf.table([['Favor Attr. 1'], [@character.fav_attribute1&.name]],
            width: 30.mm,
            &method(:heading_table)
  )
  pdf.table([['Favor Attr. 2'], [@character.fav_attribute2&.name]],
            width: 30.mm,
            &method(:heading_table)
  )

  pdf.move_down 10.mm

  # Other skills
  pdf.float do
    # Other skills
    pdf.table([%w(Andere\ Skills Wert Modi.),
               *@character.skills
                    .select { |skill| skill.skill_type == 'other' }
                    .sort { |a,b| a.order <=> b.order }
                    .map { |skill| [skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
              ],
              position: :right,
              &method(:property_table)
    )
  end

  # Attributes
  pdf.table([%w(Attribut Wert Modi.),
             *@character.character_attributes.map { |attr| [attr.property.name, attr.points.floor, format_modifier(attr.multiplier)] }],
            &method(:property_table)
  )

  # Major skills
  pdf.move_down 5.mm
  pdf.table([%w(Hauptskill Wert Modi.),
             *@character.skills
                  .select { |skill| skill.skill_type == 'major' }
                  .sort { |a,b| a.order <=> b.order }
                  .map { |skill| [skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
            ],
            &method(:property_table)
  )

  # Minor skills
  pdf.move_down 5.mm
  pdf.table([%w(Nebenskills Wert Modi.),
             *@character.skills
                  .select { |skill| skill.skill_type == 'minor' }
                  .sort { |a,b| a.order <=> b.order }
                  .map { |skill| [skill.property.name, skill.points.floor, format_modifier(skill.multiplier)] }
            ],
            &method(:property_table)
  )
end
