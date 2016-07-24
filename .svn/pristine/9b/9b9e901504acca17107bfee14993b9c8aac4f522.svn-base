require 'test_helper'

class ItemPrototypesControllerTest < ActionController::TestCase
  def setup 
    @rule_set = rule_sets(:two)
    @item_prototype = item_prototypes(:broadsword)
    @gm = users(:arian)

    log_in_as @gm
  end

  test "should get index" do
    get :index, rule_set_id: @rule_set
    assert_response :success
    assert_not_nil assigns(:item_prototypes)
  end

  test "should get new" do
    get :new, rule_set_id: @rule_set
    assert_response :success
  end

  test "should create item_prototype" do
    item_prototype = @rule_set.item_prototypes.new(name: 'Testoiden')
    assert_difference('ItemPrototype.count') do
      post :create, rule_set_id: @rule_set, item_prototype: { name: item_prototype.name, 
                                                              rule_set_id: @rule_set.id, 
                                                              weight: "1",
                                                              type: :melee_weapon }
    end

    assert_redirected_to rule_set_item_prototypes_path(@rule_set)
  end

  test "should get edit" do
    get :edit, rule_set_id: @rule_set, id: @item_prototype
    assert_response :success
  end

  test "should update item_prototype" do
    patch :update, rule_set_id: @rule_set, id: @item_prototype, item_prototype: { name: 'Testoids', 
                                                                                  rule_set_id: @rule_set.id,
                                                                                  weight: "1",
                                                                                  type: :melee_weapon }
    assert_redirected_to rule_set_item_prototypes_path(@rule_set)
  end

  test "should destroy item_prototype" do
    assert_difference('ItemPrototype.count', -1) do
      delete :destroy, rule_set_id: @rule_set, id: @item_prototype
    end

    assert_redirected_to rule_set_item_prototypes_path(@rule_set)
  end
end
