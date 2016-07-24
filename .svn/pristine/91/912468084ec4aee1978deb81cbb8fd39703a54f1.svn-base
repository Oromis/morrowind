# A property which computes its value from a given formula
class Formula < Property
  validates :formula, presence: true
  default_scope { order(:order, :abbr) }

  def to_s
    "Formula[#{id}] #{abbr} => #{formula}"
  end
end
