class Spell < ActiveRecord::Base
  has_attached_file :image, default_url: "/images/missing.gif",
                            styles: { normal: "200x200", medium: "150x150",
                                      small: "100x100", thumb: "32x32" }

  validates :name, presence: true
  validates :rule_set, presence: true
  validates :school, presence: true
  validates :range, presence: true
  validates_attachment_content_type :image, content_type: /\Aimage/

  validates :mana_cost, numericality: { only_integer: true }
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :min_effect, numericality: true, allow_nil: true
  validates :max_effect, numericality: true, allow_nil: true

  belongs_to :rule_set

  belongs_to :school, class_name: 'Skill'
  has_and_belongs_to_many :characters

  enum range: { melee: 0, support: 1, attack: 2 }

  def range_in_m
    { 'melee' => 2.1, 'support' => 6.5, 'attack' => 11 }[range]
  end

  def range_as_string
    range = range_in_m
    unless range.nil?
      range = "#{range} m"
    end
    range
  end

  def effect(school_value)
    unless min_effect.is_a?(Numeric) && max_effect.is_a?(Numeric)
      return nil
    end
    [min_effect, school_value / 100.0 * max_effect].max.floor
  end

  default_scope { order(:school_id, :name) }

  def as_json(options = {})
    char = options[:char]
    hash = {
      'id' => id,
      'name' => name,
      'effect' => effect(char.send(school.abbr)),
      'icon' => image.exists? ? image.url(:thumb) : nil,
      'handicap' => handicap,
      'school' => {
          'abbr' => school.abbr
      }
    }
    hash['desc'] = desc if desc
    hash['mana_cost'] = mana_cost if mana_cost
    hash['min_effect'] = min_effect.to_f if min_effect
    hash['max_effect'] = max_effect.to_f if max_effect
    hash['duration'] = duration if duration
    hash['range'] = range_as_string if range_as_string
    hash
  end
end
