class Specialization < ActiveRecord::Base
  has_attached_file :image, default_url: "/images/missing.gif",
                    styles: { small: "64x64", thumb: "32x32" }
  has_attached_file :avatar, default_url: "/images/missing.gif",
                    styles: { large: "300x580", small: "100x100" }

  validates_attachment_content_type :image, content_type: /\Aimage/
  validates_attachment_content_type :avatar, content_type: /\Aimage/
  validates :rule_set, presence: true
  validates :name, presence: true

  belongs_to :rule_set

  default_scope { order(name: :asc) }

  def as_json
    {
        'id' => id,
        'name' => name,
        'image' => image.exists? ? image.url(:small) : nil,
        'avatar' => avatar.exists? ? avatar.url(:large) : nil
    }
  end
end
