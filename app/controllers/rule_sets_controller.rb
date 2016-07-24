class RuleSetsController < ApplicationController
  before_action :ensure_logged_in
  before_action :ensure_permitted, only: [:new, :edit, :create, :update, :destroy]
  before_action :set_rule_set, only: [:show, :edit, :update, :destroy, :properties]

  add_breadcrumb "Regelsätze", :rule_sets_path

  layout 'with_sidebar'

  def index
    @rule_sets = RuleSet.all
  end

  def show
  end

  def new
    @rule_set = RuleSet.new
  end

  def edit
  end

  def properties
    @properties = @rule_set.attrs + @rule_set.skills + @rule_set.resistances
    respond_to do |format|
      format.json
    end
  end

  def create
    @rule_set = RuleSet.new(rule_set_params)

    respond_to do |format|
      if @rule_set.save
        format.html { redirect_to @rule_set, notice: 'Regelsatz erfolgreich erstellt.' }
        format.json { render :show, status: :created, location: @rule_set }
      else
        format.html { render :new }
        format.json { render json: @rule_set.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @rule_set.update(rule_set_params)
        format.html { redirect_to edit_rule_set_url(@rule_set), notice: 'Regelsatz aktualisiert.' }
        format.json { render :show, status: :ok, location: @rule_set }
      else
        format.html { render :edit }
        format.json { render json: @rule_set.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @rule_set.destroy
    respond_to do |format|
      format.html { redirect_to rule_sets_url, notice: 'Regelsatz gelöscht.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rule_set
      @rule_set = RuleSet.find(params[:id])
      if @rule_set.needs_save?
        @rule_set.save
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rule_set_params
      params.require(:rule_set).permit(:version, :activated,
          formulas_attributes: [:id, :name, :formula, :icon, :order])
    end

    def ensure_permitted
      unless current_user && current_user.has_role?(:gm)
        store_location
        redirect_to login_url
      end
    end
end
