class RacesController < ApplicationController
  before_action :ensure_logged_in
  before_action only: [:edit, :update, :destroy, :new] do
    ensure_role(:gm)
  end
  before_action :set_rule_set
  before_action :set_race, only: [:show, :edit, :update, :destroy]

  def index
    @races = @rule_set.races
  end

  def show
  end

  def new
    @race = @rule_set.races.new
  end

  def edit
  end

  def create
    @race = @rule_set.races.build(race_params)
    @race.property_modifiers.each do |mod|
      mod.owner = @race
    end

    respond_to do |format|
      if @race.save
        format.html { redirect_to rule_set_race_url(@rule_set, @race) }
        format.json { render :show, status: :created, location: @race }
      else
        format.html { render :new }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @race.update_attributes(race_params)
        Rails.cache.delete "json_race_#{@race.id}"
        format.html { redirect_to rule_set_race_url(@rule_set, @race) }
        format.json { render :show, status: :ok, location: @race }
      else
        format.html { render :edit }
        format.json { render json: @race.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @race.destroy
    respond_to do |format|
      format.html { redirect_to rule_set_races_url(@rule_set) }
      format.json { head :no_content }
    end
  end

  private
    def set_rule_set
      @rule_set = RuleSet.find(params[:rule_set_id])
      add_breadcrumb "Regelsatz #{@rule_set.version}", rule_set_path(@rule_set)
      add_breadcrumb "Rassen", rule_set_races_path(@rule_set)
    end

    def set_race
      @race = Race.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def race_params
      params.require(:race).permit(:name, :image, :rule_set_id, 
        property_modifiers_attributes: [:id,
                                        :property_id, 
                                        :operator, 
                                        :value, 
                                        :_destroy ],
        abilities_attributes: [:id,
                               :name,
                               :desc,
                               :_destroy,
                               property_modifiers_attributes: [:id,
                                                               :property_id,
                                                               :operator,
                                                               :value,
                                                               :_destroy ]
                              ]
      )
    end
end
