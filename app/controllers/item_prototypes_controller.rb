class ItemPrototypesController < ApplicationController
  before_action :ensure_logged_in
  before_action only: [:edit, :update, :destroy, :new] do
    ensure_role(:gm)
  end
  before_action :set_item_prototype, only: [:show, :edit, :update, :destroy]
  before_action :set_rule_set

  def index
    @item_prototypes = @rule_set.item_prototypes
  end

  def new 
    @item_prototype = @rule_set.item_prototypes.new
  end

  def edit
  end

  def create
    @item_prototype = @rule_set.item_prototypes.new(item_params)
    if @item_prototype.save
      respond_to do |format|
        format.html { redirect_to rule_set_item_prototypes_url(@rule_set) }
        format.json { render 'show' }
      end
    else
      respond_to do |format|
        format.html { render 'new' }
        format.json { render json: nil, status: 500 }
      end
    end
  end

  def update
    if @item_prototype.update_attributes(item_params)
      redirect_to rule_set_item_prototypes_url(@rule_set)
    else
      render 'edit'
    end
  end

  def destroy
    @item_prototype.destroy
    redirect_to rule_set_item_prototypes_url(@rule_set)
  end

  def import
    if params[:file]
      if ItemPrototype.import(params[:file], @rule_set)
        flash[:success] = 'Items erfolgreich importiert!'
      else
        flash[:danger] = 'Import fehlgeschlagen!'
      end
    else
      flash[:danger] = 'Keine Excel-Datei angegeben! Muss eine .xslx oder .xslm sein!'
    end

    redirect_to rule_set_item_prototypes_url(@rule_set)
  end

  private
    def set_rule_set
      @rule_set = RuleSet.find(params[:rule_set_id])
      add_breadcrumb "Regelsatz #{@rule_set.version}", rule_set_path(@rule_set)
      add_breadcrumb "Items", rule_set_item_prototypes_url(@rule_set)
    end

    def set_item_prototype
      @item_prototype = ItemPrototype.find(params[:id])
    end

    def item_params
      params.require(:item_prototype).permit(:name, :image, :rule_set_id,
                                             :type, :category, :desc, :value,
                                             :weight, :range, :damage, :speed,
                                             :two_handed, :armor, :clumsiness, :armor_type, :slot)
    end
end
