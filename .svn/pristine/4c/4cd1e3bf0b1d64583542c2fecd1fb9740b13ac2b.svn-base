class Birthsign < ActiveRecord::Base
  has_attached_file :image, default_url: "/images/missing.gif",
                            styles: { normal: "200x200", small: "125x125", thumb: "64x64" }

  validates_attachment_content_type :image, content_type: /\Aimage/
  validates :name, presence: true
  validates :rule_set, presence: true
  validates_associated :property_modifiers

  belongs_to :rule_set
  has_many :property_modifiers, as: :owner
  has_many :abilities, as: :owner, dependent: :destroy

  accepts_nested_attributes_for :property_modifiers, allow_destroy: true
  accepts_nested_attributes_for :abilities, allow_destroy: true

  default_scope { order(name: :asc) }

  def as_json(mode, options = {})
    case mode
      when :summary
        {
          'id' => id,
          'name' => name,
          'icon' => image.exists? ? image.url(:small) : nil
        }
      else
        super options
    end
  end
end
