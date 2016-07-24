class Slot < ActiveRecord::Base
  belongs_to :character
  belongs_to :item

  def as_json
    {
      'id' => id,
      'name' => name,
      'key' => key,
      'identifier' => identifier,
      'primary_type' => primary_type,
      'item' => item ? item.id : nil
    }
  end
end
