require File.expand_path('../../test_helper', __FILE__)

class HookToActionTest < ActiveSupport::TestCase
  fixtures_for_creating_issues
  
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

  def test_knows_all_event_sources
    expected=[Gamification::HookToAction::EVENT_SOURCE_ISSUE].sort
    assert_equal expected, Gamification::HookToAction.event_sources
  end 

  def test_knows_all_event_names
    expected=[
      Gamification::HookToAction::EVENT_NAME_ON_CREATE,
      Gamification::HookToAction::EVENT_NAME_ON_STATUS_CHANGE,
      Gamification::HookToAction::EVENT_NAME_ON_UPDATE_WITHOUT_STATUS_CHANGE,
      Gamification::HookToAction::EVENT_NAME_ON_UPDATE,
      Gamification::HookToAction::EVENT_NAME_ON_CLOSE
      ].sort
    assert_equal expected, Gamification::HookToAction.event_names
  end 

  def test_process_event_from_issue_on_create
    stub_game_with(fake_game)
    hook1=create_issue_hook_on(:create, "action1")
    hook2=create_issue_hook_on(:create, "action2")
    hook3=create_issue_hook_on(:update, "action3")
    played_actions=fake_game.actions_played.size
    assert_equal 0, played_actions

    issue = create_issue

    assert_equal played_actions+2, fake_game.actions_played.size
    assert_equal hook1.action_id, fake_game.actions_played[-2]
    assert_equal hook2.action_id, fake_game.actions_played.last 
  end

  private

    def create_issue_hook_on(event_name, action_id)
      options={
        event_source: Gamification::HookToAction::EVENT_SOURCE_ISSUE,
        event_name: Gamification::HookToAction::EVENT_NAME_ON_CREATE,
        action_id: "action1"
      }
      
      case event_name
      when :create
        options[:event_name]= Gamification::HookToAction::EVENT_NAME_ON_CREATE
      when :update  
        options[:event_name]= Gamification::HookToAction::EVENT_NAME_ON_UPDATE
      else
        raise "Unrecognized event name symbol"  
      end  
      
      Gamification::HookToAction.new(options)
    end
end
