require File.expand_path('../../test_helper', __FILE__)

class HookToActionTest < ActiveSupport::TestCase
  
   def test_play_action
    hook=Gamification::HookToAction.new(
        {
          event_source: Gamification::HookToAction::EVENT_SOURCE_ISSUE,
          event_name: Gamification::HookToAction::EVENT_NAME_ON_UPDATE,
          action_id: "action1"
        }
      )
    stub_game_with(fake_game)
    played_actions=fake_game.actions_played.size
    player=fake_game.players.to_a.first

    hook.play_action(player)
 
    assert_equal played_actions+1, fake_game.actions_played.size
    assert_equal hook.action_id, fake_game.actions_played.last 
   end 


end
