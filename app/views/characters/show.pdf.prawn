prawn_document do |pdf|
  pdf.stroke_axis
  pdf.stroke_circle [0, 0], 10

  pdf.bounding_box([100, 300], :width => 300, :height => 200) do
    pdf.stroke_bounds
    pdf.stroke_circle [0, 0], 10
  end

  pdf.text 'Hello World!'
end
