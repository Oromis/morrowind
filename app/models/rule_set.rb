class RuleSet < ActiveRecord::Base
  # --------------------------------------------------------------------------------
  # Constants affecting some calculations in the system.
  # These constants should probably be moved to the database as properties of a
  # RuleSet.
  # --------------------------------------------------------------------------------

  def self.encumberance_factor(key)
    case key
      when :attack then 2
      when :parry then 1
      else 0
    end
  end

  def self.combat_value_factor
    1.0 / 25.0
  end

  def self.strength_factor_offset
    0.5
  end

  def self.strength_factor_gain
    0.01
  end

  # --------------------------------------------------------------------------------
  # ActiveRecord settings
  # --------------------------------------------------------------------------------
  after_initialize :init_formulas

  validates :version, presence: true

  scope :active, -> { where(activated: true) }

  has_many :races
  has_many :birthsigns
  has_many :specializations
  has_many :skills
  has_many :resistances
  has_many :formulas
  has_many :item_prototypes
  has_many :spells

  # --------------------------------------------------------------------------------
  # Attention: The "attributes" collection is named "attrs" because ActiveRecords
  # already defines a method called "attributes"!
  # --------------------------------------------------------------------------------
  has_many :attrs, foreign_key: "rule_set_id", class_name: "Attribute"

  accepts_nested_attributes_for :formulas

  def needs_save?
    @needs_save
  end

  def formula_by_abbr(abbr)
    formulas.select { |f| f.abbr == abbr }.first
  end

  def property_by_abbr(abbr)
    Property.find_by(rule_set_id: self.id, abbr: abbr)
  end

  # Returns all valid properties for this rule set
  def properties
    Property.where(rule_set_id: self.id).order(:abbr)
  end

  # Returns an array containing arrays of arrays. First nest is sorted
  # by type, second by categeory, third contains actual ItemPrototypes
  # sorted by slot and name
  def items_by_type
    items_by_types = Hash.new { |h,k| h[k] =
                             Hash.new { |hi,ki| hi[ki] = [] } }
    # Sort items by type and category and put them in nested hashes
    self.item_prototypes.order(:type, :category, :slot, :name)
      .each do |item| 
        items_by_types[item.type][item.category] << item
      end
    items_by_types = items_by_types.values
    items_by_types.map! { |hash| hash.values }
    items_by_types
  end

  # how many level_count points are required to get a level-up
  def level_count_required
    10
  end

  def skill_type_max(type)
    case type
      when :major
        major_skill_count
      when :minor
        minor_skill_count
      else
        1000 # unlimited
    end
  end

  def RuleSet.latest
    RuleSet.active.order('version desc').first || RuleSet.new
  end

  private
    def init_formulas
      required_formulas = [
          {abbr: 'start_health', name: 'Start TP', formula: 'str+kon/2' },
          {abbr: 'max_stamina', name: 'Max Stamina', formula: 'str+wil+dex+kon', order: 0 },
          {abbr: 'mana_mult', name: 'Magicka Multiplier', formula: '1+mana_mult_buff', order: 1 },
          {abbr: 'max_mana', name: 'Max Magicka', formula: '(int*mana_mult).floor', order: 10},
          {abbr: 'hp_per_lvl', name: 'TP / Level', formula: 'kon/10' },

          # Behinderung
          {abbr: 'encumberance_from_health', name: 'Behinderung aus HP', formula:
                 'if health < 5; 6; elsif health < 11; 3; elsif health < 21; 1; else; 0; end',
           order: 4 },
          {abbr: 'encumberance_from_stamina', name: 'Behinderung aus Ausdauer', formula:
                 'case (stamina/max_stamina); when 0.5..1000; 0; when 0.25..0.5; 1; when 0.1..0.25; 3; else; 6; end',
           order: 4 },
          {abbr: 'encumberance_from_backpack', name: 'Behinderung aus Rucksack', formula:
                 'case (backpack_weight/max_backpack_weight); when 0..0.5; 0; when 0.5..0.75; 1; when 0.75..0.9; 4; else; 6; end',
           order: 4 },
          {abbr: 'encumberance_from_body', name: 'Behinderung aus Körpertraglast', formula:
                 'body_weight > max_body_weight ? 5 : 0',
           order: 4 },
          {abbr: 'encumberance', name: 'Behinderung', formula:
                 'wounds+encumberance_from_stamina+encumberance_from_backpack+encumberance_from_body', order: 5 },

          {abbr: 'max_backpack_weight', name: 'Max Rucksack Traglast', formula: 'str*3.5', order: 0},
          {abbr: 'max_body_weight', name: 'Max Körper Traglast', formula: 'kon*2.5', order: 0},
          {abbr: 'left_weapon_damage', name: 'Schaden linke Waffe', formula:
                 '(item.left_hand.min_damage+rolled_damage_left)*(item.left_hand.condition/100.0)*(0.5+str/100.0)*item.left_hand.speed'},
          {abbr: 'right_weapon_damage', name: 'Schaden rechte Waffe', formula:
                 '(item.right_hand.min_damage+rolled_damage_right)*(item.right_hand.condition/100.0)*(0.5+str/100.0)*item.right_hand.speed'},

          # Armor values of all slots
          # Head
          {abbr: 'armor_head', name: 'Rüstung Kopf', formula:
                 '0.1*armor_value(:head)', order: 5},
          # Chest
          {abbr: 'armor_chest', name: 'Rüstung Oberkörper', formula:
                 '0.3*armor_value(:chest)', order: 5},
          # Legs
          {abbr: 'armor_legs', name: 'Rüstung Beine', formula:
                 '0.1*armor_value(:legs)', order: 5},

          # Arms
          {abbr: 'armor_arms', name: 'Rüstung Arme', formula:
                 '0.1*armor_value(:arms)', order: 5},

          # Shoulders
          {abbr: 'armor_shoulders', name: 'Rüstung Schultern', formula:
                 '0.2*armor_value(:shoulders)', order: 5},

          # Füße
          {abbr: 'armor_feet', name: 'Rüstung Füße', formula:
                 '0.1*armor_value(:feet)', order: 5},

          # Schild
          {abbr: 'armor_shield', name: 'Rüstung Schild', formula:
                 '0.1*armor_value(:shield_hand)', order: 5},

          {abbr: 'armor_factor_armored', name: 'Rüstungssfaktor mit Rüstung', formula: '1.0/30.0', order: 0},
          {abbr: 'armor_factor_unarmored', name: 'Rüstungssfaktor ohne Rüstung', formula: '3.0/1000.0', order: 0},

          # Total armor for the character
          {abbr: 'total_armor', name: 'Gesamtrüstung', formula:
                 'armor_buff+armor_head+armor_chest+armor_legs+armor_arms+armor_shoulders+armor_feet+armor_shield',
                  order: 10},
          # Damage received
          {abbr: 'hp_loss', name: 'HP Verlust', formula:
                 '[damage_incoming-total_armor,damage_incoming*(1.0/3.0)].max', order: 20},

          # Evasion
          {abbr: 'evasion', name: 'Ausweichen', formula:
                 'evasion_buff+[(sch+dex+2*acr)/20,0].max'},

          # Hand-to-hand damage
          {abbr: 'hand_to_hand_damage_stamina', name: 'Faustkampfschaden gegen Ausdauer', formula: 'fau/2'},
          {abbr: 'hand_to_hand_damage_hp', name: 'Faustkampfschaden gegen HP', formula: 'fau*0.1'},

          # Laufweg
          {abbr: 'speed', name: 'Laufweg', formula: 'speed_buff+1+sch/12.0-encumberance', order: 10},
          {abbr: 'speed_2', name: 'Laufweg 2', formula: 'speed_buff+speed*ath/40-encumberance', order: 11},

          # Initiative
          {abbr: 'initiative', name: 'Initiative', formula: 'sch/5.0+initiative_roll-encumberance*4', order: 10},
      ]
      required_formulas.each do |req|
        if formula_by_abbr(req[:abbr]).nil?
          req[:formula] ||= '0'
          req[:rule_set] = self
          formulas.new(req)
          @needs_save = true
        end
      end
    end
end
