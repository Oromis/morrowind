# noinspection RubyClassVariableUsageInspection
class Item < ActiveRecord::Base
  # All field names that are delegated to the prototype are saved here
  @@prototype_fields = [:name, :weight, :value, :range, :speed, :damage, :armor, :slot, :type, :armor_type]

  extend ItemHelper

  before_save :check_prototype_fields
  after_save :invalidate_cache
  before_destroy :invalidate_cache
  self.inheritance_column = 'fake_column' # Not used, our type column has nothing to do with inheritance

  enum container: [:backpack, :body]
  enum type: { generic: 0, melee_weapon: 1, ranged_weapon: 2, armor: 3, consumable: 4, accessory: 5 }
  enum slot: [ :head, :chest, :legs, :arms, :shoulders, :feet, :hand, :back, :hip, :finger, :neck ]
  enum armor_type: [ :unarmored, :light_armor, :medium_armor, :heavy_armor ]

  attr_localized :weight, :range, :speed, :armor
  prototype_accessor :name, :weight, :value, :range, :speed, :damage, :armor
  prototype_enum_accessor :slot, Item.slots
  prototype_enum_accessor :type, Item.types
  prototype_enum_accessor :armor_type, Item.armor_types

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :value, numericality: { only_integer: true }, allow_nil: true

  validates :character, presence: true
  validates :container, presence: true
  validates :range, numericality: true, allow_nil: true
  validates :speed, numericality: true, allow_nil: true
  validates :armor, numericality: true, allow_nil: true

  # This is a special relationship for an item. If any of the fields in this item are
  # nil, the corresponding value of the prototype is returned (if it is defined, not
  # every item as a prototype). This allows standard items to be based on an item from
  # the armory and also make the properties change on a parent update.
  #
  # E.g. If I have a healing potion in my Inventory, then this Healing potion is an Item
  #   with all fields except character, prototype and quantity being nil.
  #   If I ask potion.name, it will return 'Healing Potion' because the prototype knows
  #   the name even if it is nil on the item. If the weight of the potion changes in the
  #   armory, this change is automatically reflected in the Item. No modification needed.
  #   If I now change the name of my potion to 'Awesome Potion', then this will be saved
  #   in the database and the name will no longer depend on the prototype name.
  belongs_to :prototype, class_name: 'ItemPrototype'
  belongs_to :character

  # Whether it is a weapon
  def weapon?
    melee_weapon? or ranged_weapon?
  end

  # Whether you can wear it on your body (like a piece of armor, a necklace or a sword)
  def wearable?
    weapon? or armor? or accessory?
  end

  def total_weight
    quantity * (weight || 0)
  end

  def total_value
    quantity * (value || 0)
  end

  def min_damage
    dmg = 0
    if (match = damage.match /\A\s*(\d+)(\s*\+\s*\d+[dw]\d+)?\s*\Z/)
      dmg = match[1].to_i
    end
    if ranged_weapon?
      dmg += arrow_dmg
    end
    dmg
  end

  def value=(val)
    if val.is_a? String and val.ends_with? 'k'
      val = val[0..-2].to_i * 1000
    end
    super val
  end

  default_scope { includes(:prototype).order(:index, :type, :name).references(:item_prototype) }

  def as_json
    hash = {
      'id' => id,
      'name' => name,
      'quantity' => quantity,
      'value' => value,
      'type' => type,
      'container' => container,
      'armor_type' => armor_type,
      'weight' => weight.to_f,
      'total_weight' => total_weight.to_f,
      'total_value' => total_value.to_f,
      'condition' => condition
    }
    hash['desc'] = desc if desc
    hash['slot'] = slot if slot
    hash['damage'] = damage if damage
    hash['arrow_dmg'] = arrow_dmg if arrow_dmg
    hash['prototype_id'] = prototype_id if prototype_id
    hash['range'] = range.to_f if range
    hash['armor'] = armor.to_f if armor
    hash['speed'] = speed.to_f if speed
    hash['image'] = prototype.image.url(:thumb) if prototype && prototype.image.exists?
    hash
  end

  private
    def check_prototype_fields
      if weapon?
        self.slot = :hand
      end
      if prototype
        @@prototype_fields.each do |field|
          if self[field] == prototype[field]
            # Duplicate -> Delete here.
            self[field] = nil
          end
        end
      end
    end

    def invalidate_cache
      if id
        Rails.cache.delete("json_item_#{id}")
      end
      true
    end
end
