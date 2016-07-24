require 'test_helper'

class CharacterFormulaTest < ActiveSupport::TestCase

  test "init executes formula" do
    char = Character.new
    char.character_properties << CharacterAttribute.new(points_base: 30, property: Attribute.new(abbr: 'str'))
    char.character_properties << CharacterAttribute.new(points_base: 40, property: Attribute.new(abbr: 'int'))
    f = Formula.new(formula: "10+str/2")
    c = CharacterFormula.new(property: f, character: char)
    assert_equal 25, c.init(char)
    assert_equal 25, c.points

    f.formula = "str*int/2"
    assert_equal 600, c.init(char)

    f.formula = "int/3"
    assert_equal 40.0/3.0, c.init(char)

    f.formula = "invalid * 2"
    assert_equal 0, c.init(char)
    assert_not_empty char.errors
  end
end
