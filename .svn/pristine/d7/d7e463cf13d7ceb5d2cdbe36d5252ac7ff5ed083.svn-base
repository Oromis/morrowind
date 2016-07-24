class ChangeArmorCalculation < ActiveRecord::Migration
  def up
    Formula.where(abbr:'armor_skill_head').each(&:destroy!)
    Formula.where(abbr:'armor_skill_chest').each(&:destroy!)
    Formula.where(abbr:'armor_skill_legs').each(&:destroy!)
    Formula.where(abbr:'armor_skill_arms').each(&:destroy!)
    Formula.where(abbr:'armor_skill_shoulders').each(&:destroy!)
    Formula.where(abbr:'armor_skill_feet').each(&:destroy!)
    Formula.where(abbr:'armor_skill_shield').each(&:destroy!)

    Formula.where(abbr:'armor_head').each {|f|f.formula = '0.1*armor_value(:head)'; f.save!}
    Formula.where(abbr:'armor_chest').each {|f|f.formula = '0.3*armor_value(:chest)'; f.save!}
    Formula.where(abbr:'armor_legs').each {|f|f.formula = '0.1*armor_value(:legs)'; f.save!}
    Formula.where(abbr:'armor_arms').each {|f|f.formula = '0.1*armor_value(:arms)'; f.save!}
    Formula.where(abbr:'armor_shoulders').each {|f|f.formula = '0.2*armor_value(:shoulders)'; f.save!}
    Formula.where(abbr:'armor_feet').each {|f|f.formula = '0.1*armor_value(:feet)'; f.save!}
    Formula.where(abbr:'armor_shield').each {|f|f.formula = '0.1*armor_value(:shield_hand)'; f.save!}

    Formula.where(abbr:'total_armor').each do |f|
      f.formula = 'armor_buff+armor_head+armor_chest+armor_legs+armor_arms+armor_shoulders+armor_feet+armor_shield'
      f.save!
    end

    Formula.where(abbr:'armor_factor_unarmored').each do |f|
      f.formula = '3.0/1000.0'
      f.save!
    end
  end
  def down
  end
end
