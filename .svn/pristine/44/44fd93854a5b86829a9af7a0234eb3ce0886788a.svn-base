json.array! @spells do |spell|
  json.id spell.id
  json.name spell.name
  json.desc spell.desc
  json.mana_cost spell.mana_cost
  json.min_effect number_to_human(spell.min_effect)
  json.max_effect number_to_human(spell.max_effect)
  json.duration spell.duration
  json.range spell.range_in_ft
  json.handicap spell.handicap
  json.image spell.image.exists? ? spell.image.url(:thumb) : nil
  json.school do 
    json.name spell.school.name
    json.image spell.school.icon.url(:thumb)
  end
  json.check1 do
    json.id spell.school.check1.id
    json.name spell.school.check1.name
    json.abbr spell.school.check1.abbr
    json.image spell.school.check1.icon.url(:thumb)
  end
  json.check2 do
    json.id spell.school.check2.id
    json.name spell.school.check2.name
    json.abbr spell.school.check2.abbr
    json.image spell.school.check2.icon.url(:thumb)
  end
end
