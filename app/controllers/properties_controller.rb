class PropertiesController < ApplicationController
  before_action :ensure_logged_in
  before_action only: [:edit, :update, :destroy, :new] do
    ensure_role(:gm)
  end
  before_action :set_rule_set
  before_action :set_property, only: [:edit, :update, :destroy]

  layout 'with_sidebar'

  def index 
    @properties = collection
  end

  def new 
    @property = collection.new
  end

  def create
    @property = collection.new(property_params)

    if @property.save
      redirect_to polymorphic_path([@rule_set, properties_name])
    else 
      render 'new'
    end
  end

  def update
    if @property.update_attributes(property_params)
      redirect_to polymorphic_path([@rule_set, properties_name])
    else
      render 'edit'
    end
  end

  def destroy
    @property.destroy
    redirect_to polymorphic_path([@rule_set, properties_name])
  end

  def edit
  end

  protected
    def collection
      raise NotImplementedError
    end

    def property_name
      raise NotImplementedError
    end

    def properties_name
      property_name.pluralize
    end

    def property_params
      raise NotImplementedError
    end

    def set_property
      raise NotImplementedError
    end

  private
    def set_rule_set
      @rule_set = RuleSet.find(params[:rule_set_id])
      add_breadcrumb "Regelsatz #{@rule_set.version}", rule_set_path(@rule_set)
    end
end
