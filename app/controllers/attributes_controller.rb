class AttributesController < PropertiesController
  def update
    super
    Rails.cache.delete "json_fav_attribute_#{@property.id}"
  end

  protected
    def collection
      @rule_set.attrs
    end

    def property_name
      'attribute'
    end

    def set_property
      @property = Attribute.find(params[:id])
      add_breadcrumb "Attribut", rule_set_attributes_path(@rule_set)
    end

    def property_params
      params.require(:attribute).permit(:name, :abbr, :default_value, :rule_set_id,
                                        :icon, :order)
    end
end
