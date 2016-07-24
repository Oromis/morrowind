class UpdateTo223 < ActiveRecord::Migration
  def change
    Formula.where(abbr: 'encumberance_from_stamina').each do |f|
      f.formula = 'if stamina < 20; 6; elsif stamina < 50; 3; elsif stamina < 90; 1; else; 0; end'
      f.save!
    end
    Formula.where(abbr: 'encumberance').each do |f|
      f.formula = 'wounds+encumberance_from_health+encumberance_from_stamina+encumberance_from_backpack+encumberance_from_body'
      f.save!
    end
  end
end
