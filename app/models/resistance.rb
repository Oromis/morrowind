class Resistance < Property
  default_scope { order(:order, :name) }
end
