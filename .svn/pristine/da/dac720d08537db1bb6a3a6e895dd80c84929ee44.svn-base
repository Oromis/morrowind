json.id @item_prototype.id
json.type @item_prototype.type
json.category @item_prototype.category
json.name @item_prototype.name
json.desc @item_prototype.desc
json.image @item_prototype.image.exists? ? @item_prototype.image.url(:thumb) : nil
json.weight number_to_human(@item_prototype.weight)
json.value number_to_human(@item_prototype.value, units: {thousand: 'k', million: 'm'}, format: '%n%u')
json.damage @item_prototype.damage
json.speed number_to_human(@item_prototype.speed)
json.range number_to_human(@item_prototype.range)
json.armor number_to_human(@item_prototype.armor)
json.armor_type @item_prototype.armor_type
json.slot @item_prototype.slot