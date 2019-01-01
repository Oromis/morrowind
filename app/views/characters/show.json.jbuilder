char = @character
json.id               char.id
json.name             char.name
json.status           char.status
json.creating         char.creating?
json.title            char.title
json.level            char.level
json.level_count      char.level_count
json.rules_compliant  char.rules_compliant?

json.health     char.health
json.max_health char.max_health
json.stamina    char.stamina
json.mana       char.mana
json.mana_mult_buff char.mana_mult_buff
json.wounds     char.wounds
json.armor_buff number_to_human(char.armor_buff)
json.damage_incoming number_to_human(char.damage_incoming)

json.rolled_damage_left char.rolled_damage_left
json.rolled_damage_right char.rolled_damage_right
json.initiative_roll char.initiative_roll

json.offensive_buff char.offensive_buff
json.defensive_buff char.defensive_buff
json.evasion_buff char.evasion_buff
json.speed_buff char.speed_buff

json.notes char.notes

# Directly inject computed (formula) values into the object
char.formulas.each do |formula|
  json.set! formula.property.abbr, number_to_human(formula.points)
end

json.race do
  if char.race
    json.id     char.race.id
    json.name   char.race.name
    json.icon   char.race.image.url(:normal)
  else
    json.null!
  end
end

json.birthsign do
  if char.birthsign
    json.id    char.birthsign.id
    json.name  char.birthsign.name
    json.icon  char.birthsign.image.url(:small)
  else
    json.null!
  end
end

json.specialization do
  if char.specialization
    json.id   char.specialization.id
    json.name char.specialization.name
    json.image char.specialization.image.url(:small) if char.specialization.image.exists?
    json.avatar char.specialization.avatar.url(:large) if char.specialization.avatar.exists?
  else
    json.null!
  end
end

json.fav_attribute1 do
  if char.fav_attribute1
    json.id   char.fav_attribute1.id
    json.name char.fav_attribute1.name
    json.icon char.fav_attribute1.icon.url(:thumb)
  else
    json.null!
  end
end
json.fav_attribute2 do
  if char.fav_attribute2
    json.id   char.fav_attribute2.id
    json.name char.fav_attribute2.name
    json.icon char.fav_attribute2.icon.url(:thumb)
  else
    json.null!
  end
end

json.attributes char.character_attributes do |prop|
  json.id         prop.id
  json.name       prop.property.name
  json.abbr       prop.property.abbr
  json.icon       prop.property.icon.exists? ? prop.property.icon.url(:thumb) : nil
  json.points_base prop.points_base
  json.points_buff prop.points_buff
  json.points_gained prop.points_gained
  json.points     prop.points
  json.order      prop.order
  json.multiplier prop.multiplier
  json.points_to_add prop.points_to_add
end
json.skills char.skills do |prop|
  json.id         prop.id
  json.name       prop.property.name
  json.abbr       prop.property.abbr
  json.icon       prop.property.icon.exists? ? prop.property.icon.url(:thumb) : nil
  json.points_base prop.points_base
  json.points_buff prop.points_buff
  json.points_gained prop.points_gained
  json.points     prop.points
  json.skill_type prop.skill_type
  json.order      prop.order
  json.multiplier prop.multiplier
  json.is_school_of_magic prop.property.school_of_magic
  json.weapon_skill prop.property.weapon_skill?
  if prop.property.weapon_skill?
    json.battle_points prop.battle_points
    json.skills_distributable prop.property.both?
    json.points_offensive prop.points_offensive
    json.points_defensive prop.points_defensive
    json.attack number_to_human(prop.attack)
    json.parry number_to_human(prop.parry)
  end
  if prop.property.school_of_magic?
    json.check1 prop.property.check1.abbr
    json.check2 prop.property.check2.abbr
  end
end
json.resistances char.resistances do |prop|
  json.id         prop.id
  json.name       prop.property.name
  json.abbr       prop.property.abbr
  json.icon       prop.property.icon.exists? ? prop.property.icon.url(:thumb) : nil
  json.points_base prop.points_base
  json.points_buff prop.points_buff
  json.points_gained prop.points_gained
  json.points     prop.points
  json.order      prop.order
end

grouped_items = char.items.group_by {|i| i.container }
json.containers Item.containers do |container|
  json.key container[0]
  json.name I18n.t "activerecord.attributes.item.container.#{container[0]}"
  json.weight number_to_human(char.send("#{container[0]}_weight"))
  if char.respond_to? "max_#{container[0]}_weight"
    json.max_weight number_to_human(char.send("max_#{container[0]}_weight"))
  end

  items = grouped_items[container[0]] || []
  json.items items.sort {|a,b| a.index <=> b.index} do |item|
    json.(item, :id, :name, :desc, :quantity, :value, :type, :slot, :container, :damage, :armor_type)
    json.prototype_id item.prototype_id
    json.weight number_to_human(item.weight)
    json.total_weight number_to_human(item.total_weight)
    json.range number_to_human(item.range)
    json.armor number_to_human(item.armor)
    json.speed number_to_human(item.speed)
    json.condition number_to_human(item.condition)
    if item.prototype && item.prototype.image.exists?
      json.image item.prototype.image.url(:thumb)
    end
  end
end

json.slots char.slots do |slot|
  json.id slot.id
  json.name slot.name
  json.key slot.key
  json.identifier slot.identifier
  json.primary_type slot.primary_type
  json.item do
    if slot.item
      json.(slot.item, :id, :name, :desc, :quantity, :value, :type, :slot, :container, :damage, :armor_type)
      json.prototype_id slot.item.prototype_id
      json.weight number_to_human(slot.item.weight)
      json.total_weight number_to_human(slot.item.total_weight)
      json.range number_to_human(slot.item.range)
      json.armor number_to_human(slot.item.armor)
      json.speed number_to_human(slot.item.speed)
      json.condition number_to_human(slot.item.condition)
      if slot.item.prototype && slot.item.prototype.image.exists?
        json.image slot.item.prototype.image.url(:thumb)
      end
    else
      json.null!
    end
  end
end

json.spells char.spells do |spell|
  json.id spell.id
  json.name spell.name
  json.desc spell.desc
  json.mana_cost spell.mana_cost
  json.min_effect number_to_human(spell.min_effect)
  json.max_effect number_to_human(spell.max_effect)
  json.effect spell.effect(char.send(spell.school.abbr))
  json.duration spell.duration
  json.range spell.range_as_string
  json.icon spell.image.url(:thumb) if spell.image.exists?
  json.school do
    json.abbr spell.school.abbr
  end
end