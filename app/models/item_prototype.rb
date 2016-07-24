class ItemPrototype < ActiveRecord::Base
  self.inheritance_column = 'fake_column' # Not used, our type column has nothing to do with inheritance

  has_attached_file :image, default_url: "/images/missing.gif",
                            styles: { normal: "200x200", medium: "150x150", 
                                      small: "100x100", thumb: "32x32" }

  validates :name, presence: true
  validates :weight, numericality: { greater_than: 0 }
  validates :type, presence: true
  validates :value, numericality: { only_integer: true }, allow_nil: true

  validates :range, numericality: true, allow_nil: true
  validates :speed, numericality: true, allow_nil: true
  validates :armor, numericality: true, allow_nil: true

  validates_attachment_content_type :image, content_type: /\Aimage/

  belongs_to :rule_set
  has_many :items, dependent: :nullify, foreign_key: 'prototype_id'

  enum type: { generic: 0, melee_weapon: 1, ranged_weapon: 2, armor: 3, consumable: 4, accessory: 5 }
  enum slot: [ :head, :chest, :legs, :arms, :shoulders, :feet, :hand, :back, :hip, :finger, :neck ]
  enum armor_type: [ :unarmored, :light_armor, :medium_armor, :heavy_armor ]

  # Whether it is a weapon prototype
  def weapon?
    melee_weapon? or ranged_weapon?
  end

  # Whether you can wear it on your body (like a piece of armor, a necklace or a sword)
  def wearable?
    weapon? or armor? or accessory?
  end

  default_scope { order(:type, :category, :damage, :armor, :weight, :name) }

  # --------------------------------------------------------------------------
  # Excel importer
  # --------------------------------------------------------------------------

  def self.import(file, rule_set)
    charsheet = Roo::Excelx.new(file.path)

    ItemPrototype.transaction do
      logger.info '### Importing Items! ###'
      logger.info '##  Armor ... ###'
      import_armor(charsheet.sheet('Rüstkammer'), rule_set)
      logger.info '##  Weapons ... ###'
      import_weapons(charsheet.sheet('Waffenkammer'), rule_set)
      logger.info '##  Misc ... ###'
      import_misc(charsheet.sheet('Krämerladen'), rule_set)
      logger.info '### Item Import finished! ###'
    end
  end

  def self.import_armor(sheet, rule_set)
    ranges = [OpenStruct.new(col: 2, start_row: 3, end_row: sheet.last_row, armor_type: :light_armor),
              OpenStruct.new(col: 9, start_row: 3, end_row: sheet.last_row, armor_type: :medium_armor),
              OpenStruct.new(col: 16, start_row: 3, end_row: sheet.last_row, armor_type: :heavy_armor)]
    ranges.each do |range|
      (range.start_row..range.end_row).each do |row|
        name = sheet.cell(row, range.col)
        if name && name.strip.length > 0
          name = normalize_name name
          item = ItemPrototype.new
          parts = name.split /\s+/
          type = parts[-1]
          category = parts[0..-2].join(' ')
          item.category = category
          item.name = name
          item.type = :armor
          item.armor_type = range.armor_type
          item.weight = sheet.cell(row, range.col + 1)
          item.value = sheet.cell(row, range.col + 3)
          item.armor = sheet.cell(row, range.col + 4)
          item.slot = @@slot_map[type.downcase]

          format_bonus sheet.cell(row, range.col + 5), item

          if item.weight == 0
            item.weight = 0.1
          end

          unless item.slot
            logger.warn "Excel row did not match Item! Name: #{name} -> Type: #{type}"
          end

          save_item item, rule_set
        end
      end
    end
  end

  def self.import_weapons(sheet, rule_set)
    ranges = [OpenStruct.new(col: 1, start_row: 1, end_row: sheet.last_row),
              OpenStruct.new(col: 9, start_row: 1, end_row: sheet.last_row)]
    ranges.each do |range|
      category = ''
      type = :melee_weapon
      two_handed = false

      (range.start_row..range.end_row).each do |row|
        name = sheet.cell(row, range.col)
        if name && name.strip.length > 0
          if sheet.cell(row, range.col + 1).nil?
            # This is a category heading
            category = name
            type = @@ranged_weapon_categories.include?(category) ? :ranged_weapon : :melee_weapon
            two_handed = category.downcase.start_with?('2h')
          else
            # Normal weapon
            item = ItemPrototype.new
            if category == 'Pfeile' && !name.downcase.include?('pfeil')
              name += 'pfeil'
            end
            item.name = name
            item.category = category
            item.type = type
            item.weight = sheet.cell(row, range.col + 1)
            item.value = sheet.cell(row, range.col + 3)
            item.damage = sheet.cell(row, range.col + 4)
            item.speed = sheet.cell(row, range.col + 5)
            item.two_handed = two_handed
            item.slot = :hand

            if category == 'Wurfwaffen'
              item.desc = 'Kann Zauber abfangen: Probe auf (Schnelligkeit|Geschicklichkeit|Werfen)'
            end

            range_or_bonus = sheet.cell(row, range.col + 6)
            if range_or_bonus
              if (match = range_or_bonus.match(/(\d+)ft/i))
                item.range = match.captures[0].to_i
                # There might be another column after the range with a weapon bonus
                format_bonus sheet.cell(row, range.col + 7), item
              else
                format_bonus range_or_bonus, item
              end
            end

            save_item item, rule_set
          end
        end
      end
    end
  end

  def self.import_misc(sheet, rule_set)
    ranges = [OpenStruct.new(col: 2, effect: true),
              OpenStruct.new(col: 7, effect: true),
              OpenStruct.new(col: 12, effect: true),
              OpenStruct.new(col: 18, effect: false)]
    ranges.each do |range|
      category = ''

      (1..sheet.last_row).each do |row|
        name = sheet.cell(row, range.col)
        if name && name.strip.length > 0
          if sheet.cell(row, range.col + 1).nil?
            # This is a category heading
            category = name
          else
            # Normal Item
            item = ItemPrototype.new

            case category
              when 'Spezialtraenke'
                unless name.downcase.include?('trank')
                  name += 'trank'
                end
              when 'Regenerationstraenke'
                parts = name.split(' ')
                if parts.length == 2
                  parts[0] += 'r'
                  if parts[1] == 'Gesundheit'
                    parts[1] += 's'
                  end
                  parts[1] += 'trank'
                  name = parts.join(' ')
                end
              when 'Kleidung u. Zubehör'
                item.slot = @@slot_map[name.split(' ')[-1].downcase]
              else
            end

            item.name = name
            weight = sheet.cell(row, range.col + 1)

            if range.effect
              item.desc = sheet.cell(row, range.col + 2)
              value = sheet.cell(row, range.col + 3)
            else
              value = sheet.cell(row, range.col + 2)
            end
            next unless weight.is_a?(Numeric) && value.is_a?(Numeric) # Item must have a weight

            item.weight = weight
            item.type = @@category_type_map[category.downcase]
            item.value = value
            item.category = category

            save_item item, rule_set
          end
        end
      end
    end
  end

  def self.normalize_name(name)
    dot_parts = name.split(/\./)  # Kais.Ketten => ['Kais', 'Ketten']
    name = dot_parts.each_with_index.map {|w,i| i == dot_parts.length - 1 ? w : w + '.'}.join(' ') # => 'Kais. Ketten'
    name.underscore.humanize.split.map(&:capitalize).join(' ') # HansDampf -> Hans Dampf
  end

  def self.save_item(item, rule_set)
    item.rule_set = rule_set
    if rule_set.item_prototypes.where(name: item.name).count == 0
      # New item
      logger.info "New Item! #{item.name} (#{item.type})"
      item.save!
    end
  end

  def self.format_bonus(bonus, item)
    if bonus
      if (match = bonus.match(/P\+(\d+)/i))
        bonus = "Parade +#{match.captures[0]}"
      end
      if item.desc
        item.desc += ', ' + bonus
      else
        item.desc = bonus
      end
    end
  end

  @@slot_map = {
      'kürass' => :chest,
      'helm' => :head,
      'schultern' => :shoulders,
      'schulter' => :shoulders,
      'beinlinge' => :legs,
      'stulpen' => :arms,
      'armstulpen' => :arms,
      'schild' => :hand,
      'turmschild' => :hand,
      'handschuhe' => :hand,
      'handschuh' => :hand,
      'hemd' => :chest,
      'stiefel' => :feet,
      'schuppenhemd' => :chest,
      'gürtel' => :hip,
      'amulet' => :neck,
      'ring' => :finger,
      'robe' => :chest,
      'hose' => :legs,
      'schuhe' => :feet,
      'waffengurt' => :hip
  }

  @@trinket_category_map = {
      'gewöhnlicher' => 'Gewöhnliche Accessoires',
      'gewöhnliche' => 'Gewöhnliche Accessoires',
      'gewöhnliches' => 'Gewöhnliche Accessoires',
      'teurer' => 'Teure Accessoires',
      'teure' => 'Teure Accessoires',
      'teures' => 'Teure Accessoires',
      'extravaganter' => 'Extravagante Accessoires',
      'extravagante' => 'Extravagante Accessoires',
      'extravagantes' => 'Extravagante Accessoires',
      'exquisiter' => 'Exquisite Accessoires',
      'exquisite' => 'Exquisite Accessoires',
      'exquisites' => 'Exquisite Accessoires',
  }

  @@ranged_weapon_categories = %w(Bögen Pfeile Wurfwaffen)

  @@category_type_map = {
      'rauschmittel' => :consumable,
      'spezialtraenke' => :consumable,
      'lesestoff' => :consumable,
      'gefäße und geschirr' => :generic,
      'kletter u. zeltzeug' => :generic,
      'handwerkmaterial' => :consumable,
      'spaß und spielerei' => :generic,
      'bedarfsgüter' => :consumable,
      'regenerationstraenke' => :consumable,
      'währung' => :generic,
      'handwerkszeug' => :generic,
      'fahrzeuge' => :generic,
      'kleidung u. zubehör' => :accessory
  }
end