json.array! @item_prototypes do |item|
  json.id item.id
  json.type item.type
  json.category item.category
  json.name item.name
  json.desc item.desc
  json.image item.image.exists? ? item.image.url(:thumb) : nil
  json.weight number_to_human(item.weight)
  json.value number_to_human(item.value, units: {thousand: 'k', million: 'm'}, format: '%n%u')
  json.damage item.damage
  json.speed number_to_human(item.speed)
  json.range number_to_human(item.range)
  json.armor number_to_human(item.armor)
  json.armor_type item.armor_type
  json.clumsiness number_to_human(item.clumsiness) if item.clumsiness > 0
  json.slot item.slot
end
