require File.expand_path('../../test_helper', __FILE__)

class HookToActionTest < ActiveSupport::TestCase
  fixtures_for_creating_issues
  
  def setup
    User.current=User.find(3)
    create_player(User.current, "player1")
  end  

  def test_play_action
    hook=Gamification::HookToAction.new(
        {
          event_source: Gamification::HookToAction::EVENT_SOURCE_ISSUE,
          event_name: Gamification::HookToAction::EVENT_NAME_ON_CREATE,
          action_id: "issue_created"
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
      Gamification::HookToAction::EVENT_NAME_ON_OTHER_UPDATE,
      Gamification::HookToAction::EVENT_NAME_ON_COMMENT,
      Gamification::HookToAction::EVENT_NAME_ON_CLOSE
      ].sort
    assert_equal expected, Gamification::HookToAction.event_names
  end 

  def test_process_event_from_issue_on_create
    stub_game_with(fake_game)
    hook1=create_issue_hook_on(:create, "issue_created")
    hook2=create_issue_hook_on(:create, "issue_status_change")
    hook3=create_issue_hook_on(:comment, "issue_commented")
    played_actions=fake_game.actions_played.size
    assert_equal 0, played_actions

    issue = create_issue

    assert_equal played_actions+2, fake_game.actions_played.size
    assert_equal hook1.action_id, fake_game.actions_played[-2]
    assert_equal hook2.action_id, fake_game.actions_played.last 
  end

  def test_process_event_from_issue_on_update_without_status_change
    stub_game_with(fake_game)
    hook1=create_issue_hook_on(:create, "issue_created")
    hook2=create_issue_hook_on(:status_change, "issue_status_change")
    hook3=create_issue_hook_on(:other_update, "issue_definition_updated") #this one will be triggered
    
    issue = create_issue
    played_actions=fake_game.actions_played.size
    assert_equal 1, played_actions
    
    issue.description="New description"
    issue.save!
    
    assert_equal played_actions+1, fake_game.actions_played.size
    assert_equal hook3.action_id, fake_game.actions_played.last 
  end

 def test_process_event_from_issue_on_update_with_status_change
    stub_game_with(fake_game)
    hook1=create_issue_hook_on(:create, "issue_created")
    hook2=create_issue_hook_on(:status_change, "issue_status_change") #this one will be triggered
    hook3=create_issue_hook_on(:other_update, "issue_definition_updated") 
    hook4=create_issue_hook_on(:close, "issue_closed") 

    issue = create_issue
    played_actions=fake_game.actions_played.size
    assert_equal 1, played_actions
    
    issue.status_id=2 #assigned
    issue.save!
    
    assert_equal played_actions+1, fake_game.actions_played.size
    assert_equal hook2.action_id, fake_game.actions_played.last 
  end

  def test_process_event_from_issue_on_close
    stub_game_with(fake_game)
    hook1=create_issue_hook_on(:create, "issue_created")
    hook2=create_issue_hook_on(:status_change, "issue_status_change") #this one will be triggered
    hook3=create_issue_hook_on(:other_update, "issue_definition_updated") 
    hook4=create_issue_hook_on(:close, "issue_closed") #this one will be triggered

    issue = create_issue
    played_actions=fake_game.actions_played.size
    assert_equal 1, played_actions
    
    issue.status_id=5 #closed
    issue.save!
    
    assert_equal played_actions+2, fake_game.actions_played.size
    assert_equal hook4.action_id, fake_game.actions_played[-2]
    assert_equal hook2.action_id, fake_game.actions_played.last 
  end

   def test_process_event_from_issue_on_comment
     #comment issue is done by creating journal with notes
    stub_game_with(fake_game)
    hook1=create_issue_hook_on(:create, "issue_created")
    hook2=create_issue_hook_on(:comment, "issue_commented")
    
    issue = create_issue
    played_actions=fake_game.actions_played.size
    assert_equal 1, played_actions
    
    #this should trigger action
    issue.journals << Journal.new(notes: "My notes => commented")
    
    #this should not trigger action
    issue.journals << Journal.new(private_notes: "My private notes => commented")

    #this should not trigger action
    just_issue_change_info=Journal.new(notes: "")
    just_issue_change_info.details << JournalDetail.new(:property => "attr",:prop_key => "some_id", old_value: "old", value: "new")
    issue.journals << just_issue_change_info

    assert_equal played_actions+1, fake_game.actions_played.size
    assert_equal hook2.action_id, fake_game.actions_played.last 
  end

  private

    def create_issue_hook_on(event_name, action_id)
      options={
        event_source: Gamification::HookToAction::EVENT_SOURCE_ISSUE,
        action_id: action_id
      }
      
      case event_name
      when :create
        options[:event_name]= Gamification::HookToAction::EVENT_NAME_ON_CREATE
      when :other_update  
        options[:event_name]= Gamification::HookToAction::EVENT_NAME_ON_OTHER_UPDATE
      when :comment  
        options[:event_name]= Gamification::HookToAction::EVENT_NAME_ON_COMMENT
      when :close 
        options[:event_name]= Gamification::HookToAction::EVENT_NAME_ON_CLOSE
      when :status_change
        options[:event_name]= Gamification::HookToAction::EVENT_NAME_ON_STATUS_CHANGE

      else
        raise "Unrecognized event name symbol"  
      end  
      
      Gamification::HookToAction.create!(options)
    end
end
