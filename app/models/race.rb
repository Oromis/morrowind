class Race < ActiveRecord::Base
  has_attached_file :image, default_url: "/images/missing.gif",
                              styles: { large: "200x200", normal: "150x150", small: "100x100", thumb: "48x48" }

  validates_attachment_content_type :image, content_type: /\Aimage/
  validates :rule_set, presence: true
  validates :name, presence: true
  validates_associated :property_modifiers

  belongs_to :rule_set
  has_many :property_modifiers, as: :owner, dependent: :destroy
  has_many :abilities, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :property_modifiers, allow_destroy: true
  accepts_nested_attributes_for :abilities, allow_destroy: true

  default_scope { order(name: :asc) }

  def modifier_for(property)
    self.property_modifiers.where(property_id: property.id).take
  end

  def as_json(options = {})
    if options[:mode] == :summary
      {
        'id' => id,
        'name' => name,
        'icon' => image.exists? ? image.url(:normal) : nil,
      }
    else
      super options
    end
  end
end
