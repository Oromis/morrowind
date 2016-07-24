class CharacterProperty < ActiveRecord::Base
  after_save {
    @modified = true
    Rails.cache.delete("json_char_property_#{id}")
  }

  belongs_to :character
  belongs_to :property

  def init(_)
    self.points_base = 0
  end

  def post_init(_)
  end

  def points
    return 0 unless points_base
    points_base + points_gained + points_buff
  end

  def update

  end

  def modified?
    @modified
  end

  def to_s
    "#{self.class.name}[#{id}]: #{points_base}+#{points_gained}+#{points_buff}"
  end

  # Gains (or looses for negative values) points in this CharacterProperty.
  # Also modifies the multiplier value of this property
  # @param delta [Integer] By how many points the points_gained field should change
  # @return [Integer] The difference in multiplier points which resulted in this change
  def gain_points(delta)
    self.points_gained += delta
    max_points = 100

    # Total points must not exceed 100
    if points_base + points_gained > max_points
      delta -= max_points - (points_base + points_gained)
      self.points_base = max_points - points_gained
    end

    # Increase the multiplier
    gain_multiplier delta
  end

  # Gains (or looses) multiplier points for this property.
  #
  # @param delta [Integer] The number of points by which the property's multiplier should change.
  # @return [Integer] The amount by which the multiplier actually changed
  #     (it can never be negative).
  def gain_multiplier(delta)
    self.multiplier += delta
    if multiplier < 0
      delta -= multiplier
      self.multiplier = 0
    end
    delta
  end

  #default_scope { order(:order) }
  default_scope { includes(:property) }
end
