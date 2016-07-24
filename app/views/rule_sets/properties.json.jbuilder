@properties.each do |prop|  
  json.set! prop.abbr do
    json.id prop.id
    json.abbr prop.abbr
    json.name prop.name
    json.icon prop.icon.url(:thumb)
  end
end

