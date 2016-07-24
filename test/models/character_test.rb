require 'test_helper'

class CharacterTest < ActiveSupport::TestCase
  def setup
    @user = users(:david)
    @char = characters(:nazir)
  end
  
  test "should be valid" do
    assert @char.valid?
  end

  test "name mandatory" do
    @char.name = ''
    assert_not @char.valid?
  end

  test "user mandatory" do 
    @char.user = nil
    assert_not @char.valid?
  end

  test "rule set mandatory" do
    @char.rule_set_id = nil
    assert_not @char.valid?
  end

  test "destroying user deletes char" do
    assert_difference 'Character.count', -1 do
      @char.destroy
    end
  end

  test "setup properties does its job" do
    @char.character_properties = []
    @char.send(:setup_properties)
    assert_equal @char.rule_set.properties.size, @char.character_properties.size
  end

  test "property by abbr works" do
    @char.save!
    @char.reload
    assert_nil @char.property('something')
    str = @char.property('str')
    assert_not_nil str
    assert_instance_of CharacterAttribute, str
  end

  test 'property as method access' do
    @char.save!
    @char.property('str').points_base = 20
    assert_equal 20, @char.str
  end

  test 'delete cascade' do
    @char.save!
    assert_not_equal 0, @char.character_properties.size
    start_size = CharacterProperty.count
    @char.destroy
    assert CharacterProperty.count < start_size
  end

  test 'change_skill' do
    @char.save!
    @char.level_count = 0
    skill = @char.skills.first
    skill.major!
    assert_differences [['skill.points', 5], ['skill.multiplier', 5]] do
      assert @char.change_skill(skill.id, +5)
      assert_equal 5, @char.level_count
    end

    skill.other!
    assert_differences [['skill.points', -2], ['skill.multiplier', -2]] do
      assert @char.change_skill(skill.id, -2)
      assert_equal 5, @char.level_count
    end

    # Multiplier won't get negative
    skill.minor!
    assert_differences [['skill.points', -6], ['skill.multiplier', -3]] do
      assert @char.change_skill(skill.id, -6)
      assert_equal 0, skill.multiplier
      assert_equal 2, @char.level_count
    end

    attribute = @char.character_attributes.first
    assert_no_difference 'attribute.points' do
      assert_not @char.change_skill(attribute.id, +1)
    end
  end

  test "calculate weight" do
    assert @char.items.length == 2
    @char.items[0].container = :backpack
    @char.items[0].quantity = 5
    @char.items[0].weight = 10
    @char.items[1].container = :backpack
    @char.items[1].quantity = 2
    @char.items[1].weight = 15

    @char.save!
    assert_equal 5*10+2*15, @char.backpack_weight
    assert_equal 0, @char.body_weight

    @char.reload
    assert_equal 5*10+2*15, @char.backpack_weight
    assert_equal 0, @char.body_weight
  end

  test "access equipped item" do
    assert @char.items.length > 0
    left_hand = @char.slots.select {|slot| slot.identifier == 'left_hand' }[0]
    left_hand.item = @char.items[0]
    assert_equal @char.items[0], @char.item.left_hand
  end
end
