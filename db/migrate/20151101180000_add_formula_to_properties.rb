class AddFormulaToProperties < ActiveRecord::Migration
  def change
    add_column :properties, :formula, :string
  end
end
