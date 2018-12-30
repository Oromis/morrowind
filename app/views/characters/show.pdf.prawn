def heading_table(table)
  table.cells.align = :center
  table.cells.padding = 2
  table.row(0).borders = []
  table.row(1).font_style = :bold
end

def counter_box(table)
  heading_table table
  table.row(1).padding = [10, 10, 0]
  table.row(1).size = 8.mm
  table.row(1).font_style = :normal
  table.row(1).height = 15.mm
  table.row(1).border_width = 2
  table.row(1).valign = :top
end

prawn_document do |pdf|
  pdf.stroke_axis

  # Render Level box
  pdf.float do
    pdf.table([['Level'], [@character.level]], position: :right, width: 18.mm, &method(:counter_box))
    pdf.move_down 8.mm
    pdf.table([['Counter'], ['|' * @character.level_count]], position: :right, width: 18.mm, &method(:counter_box))
  end

  # Render Character base info
  pdf.table([%w(Name Rasse Sternzeichen Zunft),
             [@character.name, @character.race&.name, @character.birthsign&.name, @character.specialization&.name]],
            width: 135.mm,
            &method(:heading_table)
  )

  pdf.move_down 8.mm
  pdf.table([['Favor Attr. 1'], [@character.fav_attribute1&.name]],
            &method(:heading_table)
  )
  pdf.table([['Favor Attr. 2'], [@character.fav_attribute2&.name]],
            &method(:heading_table)
  )
end
