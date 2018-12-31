# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20181231152333) do

  create_table "abilities", force: :cascade do |t|
    t.string   "name"
    t.string   "desc"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "birthsigns", force: :cascade do |t|
    t.string   "name"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.text     "abilities"
    t.integer  "rule_set_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  add_index "birthsigns", ["rule_set_id"], name: "index_birthsigns_on_rule_set_id"

  create_table "character_properties", force: :cascade do |t|
    t.string   "type"
    t.float    "points_base"
    t.integer  "points_gained",    default: 0
    t.integer  "order",            default: 0
    t.integer  "multiplier",       default: 0
    t.integer  "property_id"
    t.integer  "character_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "skill_type",       default: 0
    t.integer  "points_buff",      default: 0
    t.integer  "points_offensive", default: 0
    t.integer  "points_defensive", default: 0
    t.decimal  "attack",           default: 0.0
    t.decimal  "parry",            default: 0.0
  end

  add_index "character_properties", ["character_id"], name: "index_character_properties_on_character_id"
  add_index "character_properties", ["property_id"], name: "index_character_properties_on_property_id"

  create_table "characters", force: :cascade do |t|
    t.string   "name"
    t.integer  "level",               default: 1
    t.integer  "level_count",         default: 0
    t.integer  "user_id"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "race_id"
    t.integer  "rule_set_id"
    t.integer  "status",              default: 0
    t.integer  "birthsign_id"
    t.integer  "specialization_id"
    t.integer  "fav_attribute1_id"
    t.integer  "fav_attribute2_id"
    t.string   "title"
    t.integer  "health",              default: 0
    t.integer  "max_health",          default: 0
    t.integer  "stamina",             default: 0
    t.integer  "mana",                default: 0
    t.decimal  "mana_mult_buff",      default: 0.0
    t.integer  "wounds",              default: 0
    t.decimal  "backpack_weight",     default: 0.0
    t.decimal  "body_weight",         default: 0.0
    t.integer  "rolled_damage_left",  default: 0
    t.integer  "rolled_damage_right", default: 0
    t.decimal  "armor_buff",          default: 0.0
    t.integer  "damage_incoming",     default: 0
    t.integer  "offensive_buff",      default: 0
    t.integer  "defensive_buff",      default: 0
    t.integer  "evasion_buff",        default: 0
    t.integer  "speed_buff",          default: 0
    t.integer  "initiative_roll",     default: 1
    t.text     "notes",               default: ""
    t.string   "location",            default: ""
    t.integer  "day",                 default: 1
    t.string   "month",               default: "morgenstern"
  end

  add_index "characters", ["race_id"], name: "index_characters_on_race_id"
  add_index "characters", ["user_id"], name: "index_characters_on_user_id"

  create_table "characters_spells", force: :cascade do |t|
    t.integer "character_id"
    t.integer "spell_id"
  end

  add_index "characters_spells", ["character_id"], name: "index_characters_spells_on_character_id"
  add_index "characters_spells", ["spell_id"], name: "index_characters_spells_on_spell_id"

  create_table "item_prototypes", force: :cascade do |t|
    t.string   "name",                             null: false
    t.integer  "type",               default: 0
    t.string   "category"
    t.string   "desc"
    t.integer  "value"
    t.decimal  "weight"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.decimal  "range"
    t.string   "damage"
    t.decimal  "speed"
    t.boolean  "two_handed"
    t.decimal  "armor"
    t.integer  "slot"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "rule_set_id"
    t.integer  "armor_type",         default: 0
    t.decimal  "clumsiness",         default: 0.0
  end

  add_index "item_prototypes", ["rule_set_id"], name: "index_item_prototypes_on_rule_set_id"

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.integer  "type",         default: 0
    t.string   "desc"
    t.integer  "quantity"
    t.integer  "value"
    t.decimal  "weight"
    t.integer  "index"
    t.integer  "container",    default: 0
    t.decimal  "range"
    t.string   "damage"
    t.decimal  "speed"
    t.decimal  "armor"
    t.integer  "slot"
    t.integer  "prototype_id"
    t.integer  "character_id",               null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "condition",    default: 100
    t.integer  "armor_type",   default: 0
    t.integer  "arrow_dmg",    default: 0
    t.decimal  "clumsiness",   default: 0.0
  end

  create_table "properties", force: :cascade do |t|
    t.string   "type"
    t.string   "name",                              null: false
    t.string   "abbr",                              null: false
    t.integer  "order",             default: 0
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "rule_set_id"
    t.integer  "default_value",     default: 40
    t.integer  "attribute_id"
    t.integer  "specialization_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "school_of_magic",   default: false
    t.integer  "check1_id"
    t.integer  "check2_id"
    t.string   "formula"
    t.boolean  "weapon_skill",      default: false
    t.integer  "weapon_skill_mode", default: 0
    t.integer  "attack_prop_1_id"
    t.integer  "attack_prop_2_id"
    t.integer  "attack_prop_3_id"
    t.integer  "parry_prop_1_id"
    t.integer  "parry_prop_2_id"
    t.integer  "parry_prop_3_id"
  end

  add_index "properties", ["abbr"], name: "index_properties_on_abbr"
  add_index "properties", ["rule_set_id"], name: "index_properties_on_rule_set_id"

  create_table "property_modifiers", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "property_id"
    t.string   "operator"
    t.decimal  "value"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "property_modifiers", ["property_id"], name: "index_property_modifiers_on_property_id"

  create_table "races", force: :cascade do |t|
    t.string   "name"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "rule_set_id"
  end

  add_index "races", ["rule_set_id"], name: "index_races_on_rule_set_id"

  create_table "resistances", force: :cascade do |t|
    t.string   "name",                          null: false
    t.string   "abbr",                          null: false
    t.integer  "order",             default: 0
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "icon_updated_at"
    t.integer  "rule_set_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "resistances", ["abbr"], name: "index_resistances_on_abbr"
  add_index "resistances", ["rule_set_id"], name: "index_resistances_on_rule_set_id"

  create_table "rule_sets", force: :cascade do |t|
    t.string   "version"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.boolean  "activated"
    t.integer  "fav_attr_bonus",       default: 10
    t.integer  "minor_skill_count",    default: 5
    t.integer  "minor_skill_base",     default: 15
    t.integer  "major_skill_count",    default: 5
    t.integer  "major_skill_base",     default: 30
    t.integer  "other_skill_base",     default: 5
    t.integer  "specialization_bonus", default: 5
  end

  create_table "slots", force: :cascade do |t|
    t.string   "name"
    t.string   "key"
    t.integer  "character_id",                   null: false
    t.integer  "item_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "primary_type", default: "armor"
    t.string   "identifier"
  end

  add_index "slots", ["character_id"], name: "index_slots_on_character_id"
  add_index "slots", ["item_id"], name: "index_slots_on_item_id"

  create_table "specializations", force: :cascade do |t|
    t.string   "name"
    t.integer  "rule_set_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  add_index "specializations", ["rule_set_id"], name: "index_specializations_on_rule_set_id"

  create_table "spells", force: :cascade do |t|
    t.string   "name"
    t.string   "desc"
    t.integer  "mana_cost"
    t.decimal  "min_effect"
    t.decimal  "max_effect"
    t.integer  "duration"
    t.integer  "range"
    t.integer  "rule_set_id"
    t.integer  "school_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "handicap",           default: 0
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.integer  "role",              default: 0
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.string   "theme"
    t.boolean  "locked",            default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true

end
