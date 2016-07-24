class Skill < Property
  belongs_to :attr, foreign_key: 'attribute_id', class_name: 'Attribute'
  belongs_to :specialization
  belongs_to :check1, class_name: 'Attribute'
  belongs_to :check2, class_name: 'Attribute'

  validates :attr, presence: true
  validates :specialization, presence: true

  enum weapon_skill_mode: [:both, :only_offensive, :only_defensive]

  def offensive?
    both? or only_offensive?
  end

  def defensive?
    both? or only_defensive?
  end

  default_scope { order(:order, :name) }
end
