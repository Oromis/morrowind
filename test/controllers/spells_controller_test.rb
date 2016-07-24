require 'test_helper'

class SpellsControllerTest < ActionController::TestCase
  def setup
    @rule_set = rule_sets(:one)
    @spell = spells(:firebite)
    @gm = users(:arian)

    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
    assert_not_nil assigns(:spells)
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
  end

  test "should create spell" do
    spell = @rule_set.spells.new(name: 'Grausamer Tod')
    assert_difference('Spell.count') do
      post :create, rule_set_id: @rule_set, spell: { name: spell.name,
                                                     rule_set_id: @rule_set.id,
                                                     mana_cost: 10,
                                                     range: :melee,
                                                     school_id: properties(:axe).id }
    end

    assert_redirected_to rule_set_spells_path(@rule_set)
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @spell
    assert_response :success
  end

  test "should update spell" do
    patch :update, rule_set_id: @rule_set, id: @spell, spell: { name: 'Testoids',
                                                                rule_set_id: @rule_set.id,
                                                                mana_cost: 10,
                                                                range: :melee,
                                                                school: properties(:axe) }
    assert_redirected_to rule_set_spells_path(@rule_set)
  end

  test "should destroy spell" do
    assert_difference('Spell.count', -1) do
      delete :destroy, rule_set_id: @rule_set, id: @spell
    end

    assert_redirected_to rule_set_spells_path(@rule_set)
  end
end
