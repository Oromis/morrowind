class CharactersController < ApplicationController
  before_action :logged_in_user
  before_action :set_character, only: [ :show, :update, :destroy, :skill, :items, :slot_changed, :spell, :level_up ]
  before_action :permitted_user, except: :all_index
  before_action :write_allowed, only: [ :new, :create, :update, :destroy, :skill, :items, :slot_changed, :spell, :level_up ]

  layout 'with_sidebar'

  def index
    @characters = @user.characters
  end

  def all_index
    if current_user.has_role?(:gm)
      @characters = Character.all
      @user = current_user
    else
      redirect_to root_url, status: 403
    end
  end

  def new
    # @type @character [Character]
    @character = @user.characters.new
    @character.rule_set = RuleSet.latest
  end

  def create
    @character = @user.characters.build(char_params)
    if @character.save
      redirect_to user_character_url(@user, @character)
    else
      render 'new'
    end
  end

  def show
    respond_to do |format|
      format.html { render layout: 'charsheet' }
      format.json { render json: char_to_json(@character) }
      format.pdf { render :show }
    end
  end

  def update
    # t_update = 0
    # t_render = 0
    # total = Benchmark.measure do
    #   success = false
      # t_update = Benchmark.measure do
        success = @character.update_attributes(char_params)
      # end
      # t_render = Benchmark.measure do
      if success
        respond_to do |format|
          format.html { redirect_to @character }
          format.json { render json: char_to_json(@character) }
        end
      else
        respond_to do |format|
          format.html { redirect_to @character }
          format.json { render json: char_to_json(@character), status: 500 }
        end
      end
      # end
    # end
    # logger.warn("##### Update: #{(t_update.real*1000).to_i}ms")
    # logger.warn("##### Render: #{(t_render.real*1000).to_i}ms")
    # logger.warn("##### Update + Render: #{(total.real*1000).to_i}ms")
  end

  def destroy
    @character.destroy
    redirect_to user_characters_url(@user)
  end

  def skill
    skill_id = params[:skill_id]
    delta = params[:delta]
    if skill_id && delta
      if @character.change_skill(skill_id, delta)
        @character.save
        #@character.partial_update!
      else
        flash[:danger] = 'Modifying the Skill failed.'
      end
    else
      flash[:danger] = 'skill_id or delta missing!'
    end
    respond_to do |format|
      format.html { redirect_to @character }
      format.json { render json: char_to_json(@character) }
    end
  end

  def items
    # Create, update or delete item
    if (item_id = item_params[:id])
      item = @character.items.find item_id
      if item_params[:_destroy]
        success = @character.items.delete item
      else
        success = item.update_attributes item_params
      end
    else
      item = @character.items.new(item_params)
      success = item.save!
    end

    if success
      # The Character's items changed -> save it
      @character.save!
    end

    respond_to do |format|
      format.html { redirect_to @character }
      format.json { render json: char_to_json(@character) }
    end
  end

  def slot_changed
    if (slot = @character.slots.detect {|slot| slot.id == params[:slot_id]})
      if params[:item_id]
        slot.item = @character.items.find params[:item_id]
      else
        slot.item = nil
      end
      @character.save!
    end

    respond_to do |format|
      format.html { redirect_to @character }
      format.json { render json: char_to_json(@character) }
    end
  end

  def spell
    if (spell_id = params[:spell_id])
      if params[:perform] == 'add'
        unless @character.spells.where(id: spell_id).exists?
          @character.spells << Spell.find(spell_id)
        end
      elsif params[:perform] == 'destroy'
        @character.spells.delete(@character.spells.find(spell_id))
      else
        redirect_to root_url, status: 400
        return
      end
      @character.save!
    end

    respond_to do |format|
      format.html { redirect_to @character }
      format.json { render json: char_to_json(@character) }
    end
  end

  def level_up
    attributes = params[:attributes].
        map { |abbr| @character.property(abbr) }.select { |p| p != nil }
    if @character.level_count < 10 || attributes.length != 3
      redirect_to root_url, status: 400
    end

    @character.level_up attributes

    @character.save!

    respond_to do |format|
      format.html { redirect_to @character }
      format.json { render json: char_to_json(@character) }
    end
  end

  private
    def char_params
      params.require(:character).permit(
          :name, :race_id, :rule_set_id, :birthsign_id,
          :specialization_id,
          :fav_attribute1_id, :fav_attribute2_id,
          :health, :mana, :stamina,
          :mana_mult_buff, :wounds,
          :rolled_damage_left, :rolled_damage_right,
          :armor_buff, :damage_incoming,
          :offensive_buff, :defensive_buff, :evasion_buff,
          :initiative_roll, :speed_buff, :notes, :level, :level_count,
          :max_health, :location, :day, :month,
          character_properties_attributes:
              [:id, :points_buff, :points_gained, :order, :skill_type,
               :points_offensive, :points_defensive],
          items_attributes:
              [:id, :name, :desc, :quantity, :weight, :damage, :range, :armor, :slot,
               :container, :speed, :value, :type, :index, :condition, :armor_type, :arrow_dmg])
    end

    def item_params
      params.require(:item).permit(
          :id, :name, :desc, :quantity, :weight, :damage, :range, :armor, :slot,
          :container, :speed, :value, :type, :index, :prototype_id, :condition,
          :armor_type, :arrow_dmg, :clumsiness, :_destroy)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = 'Bitte einloggen!'
        redirect_to login_url
      end
    end

    def set_character
      @character = Character.find(params[:id])
    end

    def permitted_user
      user_id = params[:user_id]
      if user_id
        @user = User.find(user_id)
      elsif @character
        @user = @character.user
      else
        flash[:danger] = 'Kein Benutzer feststellbar!'
        redirect_to root_url, status: 403
      end

      unless current_user?(@user) || current_user.has_role?(:gm)
        flash[:danger] = 'An fremden Characteren herumzudoktern ist verboten!'
        redirect_to root_url, status: 403
      end
    end

    def write_allowed
      if current_user.guest?
        flash[:danger] = 'Aktion für Gäste verboten!'
        redirect_to root_url, status: 403
      end
    end

    def char_to_json(char)
      Oj.dump(char.as_json, mode: :object, indent: 0)
    end
end
