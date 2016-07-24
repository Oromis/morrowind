class SkillsController < PropertiesController
  protected
    def collection
      @rule_set.skills
    end

    def property_name
      "skill"
    end

    def set_property
      @property = Skill.find(params[:id])
      add_breadcrumb "Skills", rule_set_skills_path(@rule_set)
    end

    def property_params
      params.require(:skill).permit(:name, :abbr, :icon, :rule_set_id, 
                                    :attribute_id, :specialization_id,
                                    :school_of_magic, :check1_id, :check2_id,
                                    :order, :weapon_skill, :weapon_skill_mode)
    end
end
