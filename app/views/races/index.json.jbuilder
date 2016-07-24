json.array! @races do |race|
  json.id     race.id
  json.name   race.name
  json.icon   race.image.url(:normal)
end