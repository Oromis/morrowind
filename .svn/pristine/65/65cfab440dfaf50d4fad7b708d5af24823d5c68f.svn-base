class SpecializationsController < ApplicationController
  before_action :ensure_logged_in
  before_action only: [:edit, :update, :destroy, :new] do
    ensure_role(:gm)
  end
  before_action :set_rule_set
  before_action :set_specialization, only: [:show, :edit, :update, :destroy]

  layout 'with_sidebar'

  def index
    @specializations = @rule_set.specializations
  end

  def new
    @specialization = @rule_set.specializations.new
  end

  def create
    @specialization = @rule_set.specializations.build(specialization_params)

    if @specialization.save
      redirect_to rule_set_specializations_path(@rule_set)
    else
      render 'new'
    end
  end

  def update
    if @specialization.update_attributes(specialization_params)
      Rails.cache.delete "json_specialization_#{@specialization.id}"
      redirect_to rule_set_specializations_path(@rule_set)
    else
      render 'edit'
    end
  end

  def destroy
    @specialization.destroy
    redirect_to rule_set_specializations_path(@rule_set)
  end

  def edit
  end

  def show
  end

  private
    def set_rule_set
      @rule_set = RuleSet.find(params[:rule_set_id])
      add_breadcrumb "Regelsatz #{@rule_set.version}", rule_set_path(@rule_set)
      add_breadcrumb "Spezialisierungen", rule_set_specializations_path(@rule_set)
    end

    def set_specialization
      @specialization = Specialization.find(params[:id])
    end

    def specialization_params
      params.require(:specialization).permit(:name, :image, :avatar, :rule_set_id)
    end
end
