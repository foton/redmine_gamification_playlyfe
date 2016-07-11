require File.expand_path('../../test_helper', __FILE__)

class ActionVariableTest < ActiveSupport::TestCase
  fixtures :issues #eval string is tested againts first and last issue

  def setup
    @game=fake_game
    stub_game_with(@game)
    @action_id="set_a_and_b_to"
    @action_with_variables=@game.actions.find(@action_id) #have variables  'a_var_int' (required) and 'b_var_str'
  end  

  def test_can_be_created
    av=Gamification::ActionVariable.new(action_id: @action_id, variable: 'a_var_int', eval_string: 'issue.id')
    assert av.save
  end  

  def test_cannot_be_created_without_action
    av=Gamification::ActionVariable.new(action_id: "no_action_id", variable: 'a_var_int', eval_string: 'issue.id')
    refute av.valid?
    refute av.errors[:action_id].empty?
  end  

  def test_cannot_be_created_without_variable
    av=Gamification::ActionVariable.new(action_id: @action_id, variable: 'no_var', eval_string: 'issue.id')
    refute av.valid?
    refute av.errors[:variable].empty?
  end  
  
  def test_cannot_be_created_without_eval_string
    av=Gamification::ActionVariable.new(action_id: @action_id, variable: 'a_var_int', eval_string: '')
    refute av.valid?
    refute av.errors[:eval_string].empty?

    av=Gamification::ActionVariable.new(action_id: @action_id, variable: 'a_var_int', eval_string: nil)
    refute av.valid?
    refute av.errors[:eval_string].empty?

  end  

  def test_cannot_be_created_without_valid_eval_string
    av=Gamification::ActionVariable.new(action_id: @action_id, variable: 'a_var_int', eval_string: 'issssssue.vvvaleu')
    refute av.valid?
    refute av.errors[:eval_string].empty?
  end  

end  
