class BirthsignsController < ApplicationController
  before_action :ensure_logged_in
  before_action only: [:edit, :update, :destroy, :new] do
    ensure_role(:gm)
  end
  before_action :set_rule_set
  before_action :set_birthsign, only: [:show, :edit, :update, :destroy, :modifiers]

  layout 'with_sidebar'

  def index 
    @birthsigns = @rule_set.birthsigns
  end

  def show
  end

  def new 
    @birthsign = @rule_set.birthsigns.new
  end

  def edit
  end

  def create
    @birthsign = @rule_set.birthsigns.build(birthsign_params)
    @birthsign.property_modifiers.each do |mod|
      mod.owner = @birthsign
    end

    respond_to do |format|
      if @birthsign.save
        format.html { redirect_to rule_set_birthsign_url(@rule_set, @birthsign) }
        format.json { render :show, status: :created, location: @birthsign }
      else
        format.html { render :new }
        format.json { render json: @birthsign.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @birthsign.update_attributes(birthsign_params)
        Rails.cache.delete "json_birthsign_#{@birthsign.id}"
        format.html { redirect_to rule_set_birthsign_url(@rule_set, @birthsign) }
        format.json { render :show, status: :ok, location: @birthsign }
      else
        format.html { render :edit }
        format.json { render json: @birthsign.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @birthsign.destroy
    respond_to do |format|
      format.html { redirect_to rule_set_birthsigns_url(@rule_set) }
      format.json { head :no_content }
    end
  end

  private
    def set_rule_set
      @rule_set = RuleSet.find(params[:rule_set_id])
      add_breadcrumb "Regelsatz #{@rule_set.version}", rule_set_path(@rule_set)
      add_breadcrumb "Sternzeichen", rule_set_birthsigns_path(@rule_set)
    end

    def set_birthsign
      @birthsign = Birthsign.find(params[:id])
    end

    def birthsign_params
      params.require(:birthsign).permit(:name, :image, :rule_set_id,
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
