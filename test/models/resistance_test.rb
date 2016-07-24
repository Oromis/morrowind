require 'test_helper'

class ResistanceTest < ActiveSupport::TestCase
  def setup 
    @resi = properties(:fire)
    @rule_set = @resi.rule_set
  end

  test "default valid" do
    assert @resi.valid?
  end

  test "name valid" do
    @resi.name = ''
    assert_not @resi.valid?
  end

  test "abbr valid" do
    @resi.abbr = ' '
    assert_not @resi.valid?
  end
  
  test "rule_set mandatory" do
    @resi.rule_set = nil
    assert_not @resi.valid?
  end
end
