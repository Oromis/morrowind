class ResistancesController < PropertiesController
  protected
    def collection
      @rule_set.resistances
    end

    def property_name
      "resistance"
    end

    def set_property
      @property = Resistance.find(params[:id])
    end

    def property_params
      params.require(:resistance).permit(:name, :abbr, :icon, :rule_set_id, :order)
    end
end
