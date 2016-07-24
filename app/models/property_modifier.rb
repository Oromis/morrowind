class PropertyModifier < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :property

  validates :property, presence: true
  validates :operator, presence: true, inclusion: { in: %w(+ - * /) }
  validates :value, presence: true, numericality: true

  default_scope { order(operator: :asc, value: :desc); includes(:property) }

  def modify_value(value)
    eval "#{ value } #{ operator } self.value"
  end

  def modify(character_property)
    character_property.points_base = modify_value(character_property.points_base)
  end

  def to_s
    "#{property.abbr} #{operator} #{value}"
  end
end
