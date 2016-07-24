class CorrectEncumbranceFormula < ActiveRecord::Migration
  def up
    Formula.where(abbr: 'encumberance').each do |formula|
      formula.formula = 'wounds+encumberance_from_stamina+encumberance_from_backpack+encumberance_from_body'
      formula.order = 5
      formula.save!
    end
  end
  def down
    # Deliberately empty
  end
end
