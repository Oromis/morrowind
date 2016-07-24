class Ability < ActiveRecord::Base
  validates :name, presence: true
#  validates :owner, presence: true
  validates_associated :property_modifiers

  belongs_to :owner, polymorphic: true
  has_many :property_modifiers, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :property_modifiers, allow_destroy: true

  default_scope { order(name: :asc) }
end
