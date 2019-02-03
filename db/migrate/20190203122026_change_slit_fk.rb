class ChangeSlitFk < ActiveRecord::Migration
  def change
    remove_foreign_key :slots, :items
    add_foreign_key :slots, :items, on_delete: :nullify
  end
end
