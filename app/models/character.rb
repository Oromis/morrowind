include SerializationHelper

class Character < ActiveRecord::Base
  before_save :on_save
  after_initialize :on_load

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage/
  attr_accessor :delete_image
  before_validation { image.clear if delete_image == '1' }

  belongs_to :user
  belongs_to :rule_set

  belongs_to :race
  belongs_to :birthsign
  belongs_to :specialization
  belongs_to :fav_attribute1, class_name: 'Attribute'
  belongs_to :fav_attribute2, class_name: 'Attribute'

  has_many :character_properties,
           -> { includes(:property).order('"properties"."order"').references(:property) },
           autosave: true, dependent: :destroy
  has_many :items, autosave: true, dependent: :destroy
  has_many :slots, autosave: true, dependent: :destroy
  has_and_belongs_to_many :spells

  def character_attributes
    character_properties.select { |p| p.is_a?(CharacterAttribute) }
  end
  def skills
    character_properties.select { |p| p.is_a?(CharacterSkill) }
  end
  def resistances
    character_properties.select { |p| p.is_a?(CharacterResistance) }
  end
  def formulas
    character_properties.select { |p| p.is_a?(CharacterFormula) }
  end

  validates :name, presence: true
  validates :user_id, presence: true
  validates :rule_set_id, presence: true

  enum status: [ :creating, :playing ]

  accepts_nested_attributes_for :character_properties
  accepts_nested_attributes_for :items, allow_destroy: true

  # Overridden setter methods for value saturation
  def health=(health)
    super [health, max_health].min
  end

  def mana=(mana)
    super [mana, max_mana].min
  end

  def stamina=(stamina)
    super [stamina, max_stamina].min
  end

  def wounds=(wounds)
    super [0,wounds].max
  end

  def partial_update!
    @partial_update = true
  end

  def partial_update?
    @partial_update
  end

  # Checks whether the char is setup properly (i.e. has a race, birthsign,
  #   setup all abilities and skills ...)
  # @return [Boolean]
  def rules_compliant?
    !(race.nil? || birthsign.nil? || specialization.nil? || fav_attribute1.nil? || fav_attribute2.nil?)
  end

  # Retrieves a character_property by its abbreviation
  def property(abbr)
    unless @properties_by_abbr
      @properties_by_abbr = Hash[*character_properties.map { |prop| [prop.property.abbr, prop] }.flatten!]
    end
    @properties_by_abbr[abbr.to_s]
  end

  # Retrieves the character's current value of a given property (attribute, skill, resistance)
  def property_points(property)
    prop = !property.nil? && character_properties.find { |p| p.property.id == property.id }
    prop ? prop.points : 0
  end

  # Changes a character skill by the specified amount. Also modifies multipliers and
  # level count
  # @param skill_id [Integer] The id of the CharacterSkill to change
  # @param delta [Integer] The amount by which the value should change. Can be negative.
  # @return [Boolean]
  def change_skill(skill_id, delta)
    if (skill = skills.find { |skill| skill.id == skill_id })
      delta = skill.gain_points(delta)

      # Each multiplier point for a skill gives a multiplier point for the associated attribute
      if (attribute = character_attributes.find { |attr| attr.property.id == skill.property.attr.id })
        delta = attribute.gain_multiplier(delta)

        # Each multiplier point in major and minor skills gives a level count point
        if skill.gives_level_count?
          self.level_count += delta
          if level_count < 0
            self.level_count = 0
          end
        end
        return true
      end
    end
    false
  end

  # Allows to access a character's properties by their abbreviations
  # E.g.: char.str => Outputs the strength value if the char has a property with
  #   the abbr = 'str'
  def method_missing(id, *args)
    name = id.id2name
    prop = self.property(name)
    if prop
      prop.points.to_f
    else
      super
    end
  end

  def respond_to_missing?(name, *arguments)
    self.property(name.to_s).present? || super
  end

  def slot_map
    unless @slot_map
      @slot_map = Hash[self.slots.map { |slot| [slot.identifier.to_sym, slot] }]
    end
    @slot_map
  end

  def item
    unless @items_by_slot
      @items_by_slot = OpenStruct.new Hash[self.slots.map { |slot| [slot.identifier, slot.item] }]
    end
    @items_by_slot
  end

  def armor_type(slot_id)
    slot_map[slot_id].try(:item).try(:armor_type).try(:to_sym) || :unarmored
  end

  def armor_value(slot_id)
    skill = armor_skill slot_id
    case armor_type(slot_id)
      when :unarmored
        skill * skill * armor_factor_unarmored
      else
        skill * armor_factor_armored * slot_map[slot_id].item.armor
    end
  end

  # Caution: Design Flaw! Skill-Abbr-Specific labels here!
  def armor_skill(slot_id)
    type = armor_type slot_id
    case type
      when :light_armor
        l_ar
      when :medium_armor
        m_ar
      when :heavy_armor
        h_ar
      else
        o_ar
    end
  end

  def clumsiness
    # raise self.slots.select { |slot| slot.primary_type == :armor }.inspect
    self.slots
        .select { |slot| slot.primary_type == 'armor' }
        .inject(0) { |sum, slot| sum + (slot.item&.clumsiness).to_i }
        .floor
  end

  def level_up(attributes)
    # Add attribute points
    attributes.each do |attr|
      attr.points_gained += attr.points_to_add
    end

    # Refresh calculated attributes
    update_properties

    # Adjust Max HP
    self.max_health += hp_per_lvl.floor

    self.level += 1
    self.level_count -= 10

    # Reset all multipliers
    self.character_attributes.each do |attr|
      attr.multiplier = 0
    end
    self.skills.each do |skill|
      skill.multiplier = 0
    end

    # Full HP, stamina, mana
    self.health = max_health
    self.mana = max_mana
    self.stamina = max_stamina
  end

  # JSON serialization is done here instead of a jbuilder template for performance
  # reasons. Together with caching, this method takes just over 80ms to render a
  # character in production (compared to north of 300ms for jbuilder).
  def as_json
    grouped_items = items.group_by(&:container)

    json = {
      'id' => id,
      'name' => name,
      'status' => status,
      'creating' => creating?,
      'title' => title,
      'level' => level,
      'level_count' => level_count,
      'rules_compliant' => rules_compliant?,
      'health' => health,
      'max_health' => max_health,
      'stamina' => stamina,
      'mana' => mana,
      'mana_mult_buff' => mana_mult_buff.to_f,
      'wounds' => wounds,
      'armor_buff' => armor_buff.to_f,
      'damage_incoming' => damage_incoming,
      'clumsiness' => clumsiness,

      'rolled_damage_left' => rolled_damage_left,
      'rolled_damage_right' => rolled_damage_right,
      'initiative_roll' => initiative_roll,

      'offensive_buff' => offensive_buff,
      'defensive_buff' => defensive_buff,
      'evasion_buff' => evasion_buff,
      'speed_buff' => speed_buff,

      'notes' => notes,
      'location' => location,
      'day' => day,
      'month' => month,

      'race' => race && Rails.cache.fetch("json_race_#{race.id}") do
        race.as_json mode: :summary
      end,
      'birthsign' => birthsign && Rails.cache.fetch("json_birthsign_#{birthsign.id}") do
        birthsign.as_json mode: :summary
      end,
      'specialization' => specialization && Rails.cache.fetch("json_specialization_#{specialization.id}") do
        specialization.as_json
      end,
      'fav_attribute1' => fav_attribute1 && Rails.cache.fetch("json_fav_attribute_#{fav_attribute1.id}") do
        fav_attribute1.as_json(mode: :fav)
      end,
      'fav_attribute2' => fav_attribute2 && Rails.cache.fetch("json_fav_attribute_#{fav_attribute2.id}") do
        fav_attribute2.as_json(mode: :fav)
      end,

      'attributes' => character_attributes.map {|attr|
        Rails.cache.fetch("json_char_property_#{attr.id}") do
          attr.as_json
        end
      },
      'skills' => skills.map {|skill|
        Rails.cache.fetch("json_char_property_#{skill.id}") do
          skill.as_json
        end
      },
      'resistances' => resistances.map {|resi|
        Rails.cache.fetch("json_char_property_#{resi.id}") do
          resi.as_json
        end
      },

      'containers' => Item.containers.map do |container|
        {
          'key' => container[0],
          'name' => I18n.t("activerecord.attributes.item.container.#{container[0]}"),
          'weight' => send("#{container[0]}_weight").to_f,
          'max_weight' => respond_to?("max_#{container[0]}_weight") ?
                                               send("max_#{container[0]}_weight") :
                                               nil,
          'items' => (grouped_items[container[0]] || []).
              sort {|a,b| a.index <=> b.index}.
              map {|item|
                Rails.cache.fetch("json_item_#{item.id}") do
                  item.as_json
                end
              }
        }
      end,

      'slots' => slots.map {|slot| slot.as_json },
      'spells' => spells.map {|spell| spell.as_json char: self }
    }
    formulas.each do |formula|
      json[formula.property.abbr] = formula.points
    end
    json
  end

  private
    def on_load
      if creating?
        setup_properties
        setup_slots
      end
    end

    def on_save
      calculate_weight
      update_properties
      if creating?
        if level == 1
          self.max_health = start_health
        end
        # if health == 0
        #   self.health = max_health
        # end
        # if mana == 0
        #   self.mana = max_mana
        # end
        # if stamina == 0
        #   self.stamina = max_stamina
        # end
      end
    end

    # Make sure that the character has instances of all properties the rule set
    # requires
    def setup_properties
      return unless rule_set
      class_map = {
          Attribute => CharacterAttribute,
          Formula => CharacterFormula,
          Skill => CharacterSkill,
          Resistance => CharacterResistance
      }
      existing_props = character_properties.map { |ca| ca.property }
      required_props = [rule_set.attrs, rule_set.skills, rule_set.resistances, rule_set.formulas]
                           .flatten!
      new_props = required_props.reject { |prop| existing_props.include? prop }
      new_props.each do |prop|
        character_properties << class_map[prop.class].new(character: self,
                                                          property: prop,
                                                          order: prop.order)
      end
    end

    # Recalculates the values of ALL (!) properties of this character
    def update_properties
      # t_init = 0, t_mod = 0, t_formula = 0, t_formula_mod = 0, t_post_init = 0
      # t_update_properties = Benchmark.measure do
        # Reset values for everything except formulas
        # t_init = Benchmark.measure do
          character_properties.reject { |p| p.is_a?(CharacterFormula) }.each do |p|
            p.init(self)
          end
        # end

        # Apply modifiers to attributes, skills and resistances (formulas later)
        mods = []
        # t_mod = Benchmark.measure do
          mods << race.property_modifiers if race
          mods << birthsign.property_modifiers if birthsign
          mods.flatten!
          mods.reject { |m| m.property.is_a?(Formula) }.each(&method(:apply_modifier))
        # end

        # Now start to process formulas
        # t_formula = Benchmark.measure do
          character_properties.select { |p| p.is_a?(CharacterFormula) }.each do |f|
            f.init(self)
          end
        # end

        # Apply modifiers to formulas
        # t_formula_mod = Benchmark.measure do
          mods.select { |m| m.property.is_a?(Formula) }.each(&method(:apply_modifier))
        # end

        # t_post_init = Benchmark.measure do
          character_properties.each do |prop|
            prop.post_init(self)
          end
        # end
      # end

      # logger.warn("##    Init: #{(t_init.real*1000).to_i}ms")
      # logger.warn("##    Mofifiers: #{(t_mod.real*1000).to_i}ms")
      # logger.warn("##    Formula: #{(t_formula.real*1000).to_i}ms")
      # logger.warn("##    Formula Modifiers: #{(t_formula_mod.real*1000).to_i}ms")
      # logger.warn("##    Post Init: #{(t_post_init.real*1000).to_i}ms")
      # logger.warn("###   Update Properties: #{(t_update_properties.real*1000).to_i}ms")
    end

    def apply_modifier(mod)
      prop = property(mod.property.abbr)
      if prop
        mod.modify(prop)
      end
    end

    def calculate_weight
      weights = { backpack: 0, body: 0 }
      items.each do |item|
        weights[item.container.to_sym] += item.total_weight
      end
      self.backpack_weight = weights[:backpack]
      self.body_weight = weights[:body]
    end

    def setup_slots
      required_slots = [
          { name: 'Kopf', key: :head, identifier: :head, primary_type: :armor },
          { name: 'Schultern', key: :shoulders, identifier: :shoulders, primary_type: :armor },
          { name: 'Arme', key: :arms, identifier: :arms, primary_type: :armor },
          { name: 'Oberkörper', key: :chest, identifier: :chest, primary_type: :armor },
          { name: 'Rechte Hand', key: :hand, identifier: :right_hand, primary_type: :melee_weapon },
          { name: 'Linke Hand', key: :hand, identifier: :left_hand, primary_type: :melee_weapon },
          { name: 'Schild', key: :hand, identifier: :shield_hand, primary_type: :armor },
          { name: 'Beine', key: :legs, identifier: :legs, primary_type: :armor },
          { name: 'Füße', key: :feet, identifier: :feet, primary_type: :armor },
      ]
      required_slots.each do |new_slot|
        unless slots.index {|slot| slot.name == new_slot[:name]}
          new_slot[:character] = self
          slots.new(new_slot)
        end
      end
    end
end
