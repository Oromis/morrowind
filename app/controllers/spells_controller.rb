class SpellsController < ApplicationController
  before_action :ensure_logged_in
  before_action only: [:edit, :update, :destroy, :new] do
    ensure_role(:gm)
  end
  before_action :set_spell, only: [:edit, :update, :destroy]
  before_action :set_rule_set

  def index
    @spells = @rule_set.spells
    @schools = @rule_set.skills.where(school_of_magic: true)
  end

  def school_index
    @spells = @rule_set.spells.where(school_id: params[:school])
    @schools = @rule_set.skills.where(school_of_magic: true)
    render 'index'
  end

  def new 
    @spell = @rule_set.spells.new
  end

  def edit
  end

  def create 
    @spell = @rule_set.spells.new(spell_params)
    if @spell.save
      redirect_to rule_set_spells_url(@rule_set)
    else
      render 'new'
    end
  end

  def update
    if @spell.update_attributes(spell_params)
      redirect_to rule_set_spells_url(@rule_set)
    else
      render 'edit'
    end
  end

  def destroy
    @spell.destroy
    redirect_to rule_set_spells_url(@rule_set)
  end

  private
    def set_rule_set
      @rule_set = RuleSet.find(params[:rule_set_id])
      add_breadcrumb "Regelsatz #{@rule_set.version}", rule_set_path(@rule_set)
      add_breadcrumb 'Zaubersprüche', rule_set_spells_url(@rule_set)
    end

    def set_spell
      @spell = Spell.find(params[:id])
    end

    def spell_params
      params.require(:spell).permit(:name, :image, :rule_set_id,
                                    :desc, :range, :min_effect, 
                                    :max_effect, :school_id,
                                    :mana_cost, :duration, :handicap)
    end
end
