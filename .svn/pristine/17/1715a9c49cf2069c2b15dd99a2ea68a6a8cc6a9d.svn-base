class Property < ActiveRecord::Base
  after_save :invalidate_cache

  has_attached_file :icon, default_url: '/images/missing.gif',
                           styles: { normal: '128x128', thumb: '32x32' }

  validates :name, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :abbr, presence: true,
                   uniqueness: { case_sensitive: false }
  validates :rule_set, presence: true
  validates_attachment_content_type :icon, content_type: /\Aimage/

  before_save :downcase_abbr

  belongs_to :rule_set
  has_many :character_properties, dependent: :destroy

  private
    def downcase_abbr
      self.abbr = abbr.downcase
    end

    def invalidate_cache
      Rails.cache.delete_matched(/json_char_property_.*/)
    end
end
