require File.expand_path('../../test_helper', __FILE__)

class GamificationControllerTest < ActionController::TestCase
  tests GamificationController
  fixtures :users

  def setup
    @game=fake_game
    stub_game_with(@game)
    @user=User.find(2) 
    Gamification::UserToPlayer.delete_all
    @player=Gamification::UserToPlayer.create!(user_id: @user.id, player_id: "player2")
  end  

  def test_should_require_signed_in_user
    get :index
    assert_response :found   #sign_in needed
  end
    
  def test_no_index_for_nonplayer
    current_user_set_to(4)
    get :index
    assert_response :forbidden
  end

  def test_index
    current_user_set_to(:player)
    get :index
    assert_response :ok
    assert_template "gamification/index"
  end

  def test_my_scores  
    current_user_set_to(:player)
    get :my_scores
    assert_response :ok
    assert_template "gamification/player"
  #  assert assigns(:player).id == 4
  end  

  def test_player_with_id_for_admin
    current_user_set_to(:admin)
    get :player, {player_id: "player2"}
    assert_response :ok
    assert_template "gamification/player"
  end

  def test_player_with_not_existing_id_for_admin
    current_user_set_to(:admin)
    get :player, {player_id: "not_exists"}
    assert_redirected_to gamification_url
    assert_equal "Player 'not_exists' is not between Game players!", flash[:error]
  end

  def test_player_for_nonadmin
    current_user_set_to(:player)
    get :player, {player_id: 6} #dlopper2
    assert_response :forbidden
  end

  def test_actions_for_admin
    current_user_set_to(:admin)
    
    get :actions
      
    assert_response :ok
    assert_template "gamification/actions"

    assert assigns(:actions).present?
    assert_equal @game.actions.to_a.size, assigns(:actions).to_a.size

    assert assigns(:game_players).present?
    assert_equal @game.players.to_a.size, assigns(:game_players).to_a.size
  end

  def test_successfully_play_action
    current_user_set_to(:admin)
    played_actions=@game.actions_played.size

    post :play_action, {action_id: "issue_commented", player_id: "player1"}
    
    assert_response :ok
    assert_template "gamification/actions"
    assert_equal "Action 'issue_commented' was successfully played by player 'player1", flash[:notice]
    assert flash[:error].blank?
    assert_equal played_actions+1, @game.actions_played.size
    assert_equal "issue_commented", @game.actions_played.last
  end

  def test_play_action_with_no_player
    current_user_set_to(:admin)
    played_actions=@game.actions_played.size 

    post :play_action, {action_id: "issue_commented", player_id: "player100"}
    assert_response :ok
    assert_template "gamification/actions"
    assert_equal "Player 'player100' is not between Game players!", flash[:error]
    assert_equal played_actions, @game.actions_played.size
  end

  def test_play_action_with_no_action
    current_user_set_to(:admin)
    played_actions=@game.actions_played.size
    
    post :play_action, {action_id: "action100", player_id: "player1"}
    assert_response :ok
    assert_template "gamification/actions"
    assert_equal "Action 'action100' is not between actions of Game!", flash[:error]
    assert_equal played_actions, @game.actions_played.size
  end

  def test_configuration_for_admin
    current_user_set_to(:admin)
    Gamification::EventToAction.create!(event_id: "issue-create", action_id: "issue_created")
 
    get :configuration
          
    assert_response :ok
    assert_template "gamification/configuration"
    
    assert assigns(:game_players).present?
    assert_equal @game.players.to_a.size, assigns(:game_players).to_a.size
    assert assigns(:users).present?
    assert_equal User.count, assigns(:users).size
    assert assigns(:users_to_players).present?
    assert_equal Gamification::UserToPlayer.count+5, assigns(:users_to_players).size #added 5 blanks UserToPlayer objects

    assert assigns(:actions).present?
    assert_equal @game.actions.to_a.size, assigns(:actions).to_a.size
    assert assigns(:available_event_ids).present?
    assert_equal Gamification::EventToAction.available_event_ids, assigns(:available_event_ids)
    assert assigns(:events_to_actions).present?
    assert_equal Gamification::EventToAction.all, assigns(:events_to_actions)
  end

  def test_configuration_update_new
    current_user_set_to(:admin)
    Gamification::UserToPlayer.delete_all
    assert_equal 0, Gamification::UserToPlayer.count
   
    params={
      "users_to_players" => [
        {"user_id" => "1", "player_id" => "player1"},
        {"user_id" => "2", "player_id" => "player2"},
        {"user_id" => "3", "player_id" => "player2"},
        {"user_id" => "0", "player_id" => "0"},
        {"user_id" => "", "player_id" => ""}
      ],
      "events_to_actions" => [
        {"event_id" => "issue-create", "action_id" => "issue_created"},
        {"event_id" => "issue-comment", "action_id" => "issue_commented"},
      ],
      "commit" => "Save changes"      
    }
        
    put :configuration_update, params

    assert_redirected_to gamification_configuration_url
    assert flash[:error].blank?
    
    assert_equal 3, Gamification::UserToPlayer.count
    assert_equal [1], Gamification::UserToPlayer.where(player_id: "player1").pluck(:user_id)
    assert_equal [2,3], Gamification::UserToPlayer.where(player_id: "player2").pluck(:user_id).sort

    assert_equal 2, Gamification::EventToAction.count
    assert_equal 1, Gamification::EventToAction.for_issues.on_create.count
    assert_equal 1, Gamification::EventToAction.for_issues.on_comment.count
  end

  def test_configuration_update_existing
    current_user_set_to(:admin)
    Gamification::UserToPlayer.delete_all
    p11=Gamification::UserToPlayer.create!(user_id: 1, player_id: "player1") #persist
    p22=Gamification::UserToPlayer.create!(user_id: 2, player_id: "player2") #persist
    p33=Gamification::UserToPlayer.create!(user_id: 3, player_id: "player3") #will be deleted
    p42=Gamification::UserToPlayer.create!(user_id: 4, player_id: "player2") #will be deleted
    assert_equal 4, Gamification::UserToPlayer.count
    assert_equal [1], Gamification::UserToPlayer.where(player_id: "player1").pluck(:user_id)
    assert_equal [2,4], Gamification::UserToPlayer.where(player_id: "player2").pluck(:user_id).sort
    assert_equal [3], Gamification::UserToPlayer.where(player_id: "player3").pluck(:user_id).sort

    Gamification::EventToAction.create!(event_id: "issue-create", action_id: "issue_created") #persist
    Gamification::EventToAction.create!(event_id: "issue-close", action_id: "issue_closed") #persist
    Gamification::EventToAction.create!(event_id: "issue-close", action_id: "issue_status_change") #will be deleted
    assert_equal 3, Gamification::EventToAction.count
    assert_equal 1, Gamification::EventToAction.for_issues.on_create.count
    assert_equal 2, Gamification::EventToAction.for_issues.on_close.count

    
    params={
      "users_to_players" => [
        {"user_id" => "1", "player_id" => "player1"}, #already existing in DB
        {"user_id" => "2", "player_id" => "player2"}, #already existing in DB
        {"user_id" => "3", "player_id" => "player2"}, #will be created
        {"user_id" => "0", "player_id" => "0"},
        {"user_id" => "", "player_id" => ""}
      ],
      "events_to_actions" => [
        {"event_id" => "issue-create", "action_id" => "issue_created"},
        {"event_id" => "issue-comment", "action_id" => "issue_commented"},
        {"event_id" => "issue-close", "action_id" => "issue_closed"},
        {"event_id" => "issue-close", "action_id" => "issue_commented"},

      ],
      "commit" => "Save changes"      
    }
        
    put :configuration_update, params

    assert_redirected_to gamification_configuration_url
    assert flash[:error].blank?

    assert_equal 3, Gamification::UserToPlayer.count
    assert_equal [1], Gamification::UserToPlayer.where(player_id: "player1").pluck(:user_id)
    assert_equal [2,3], Gamification::UserToPlayer.where(player_id: "player2").pluck(:user_id).sort
    assert_equal [], Gamification::UserToPlayer.where(player_id: "player3").pluck(:user_id).sort

    assert_equal 4, Gamification::EventToAction.count
    assert_equal 1, Gamification::EventToAction.for_issues.on_create.count
    assert_equal 1, Gamification::EventToAction.for_issues.on_comment.count
    assert_equal 2, Gamification::EventToAction.for_issues.on_close.count
  end

  def test_get_errors_for_wrong_ids
    current_user_set_to(:admin)
    Gamification::UserToPlayer.delete_all
    assert_equal 0, Gamification::UserToPlayer.count
    assert_equal 0, Gamification::EventToAction.count
    
    params={
      "users_to_players" => [
        {"user_id" => "1", "player_id" => "player1"}, #OK
        {"user_id" => "2", "player_id" => "player200"}, #wrong
        {"user_id" => "300", "player_id" => "player2"}, #wrong
      ],
      "events_to_actions" => [
        {"event_id" => "issue-create", "action_id" => "issue_created"}, #ok
        {"event_id" => "issue-comment", "action_id" => "issue_comet"}, #wrong
        {"event_id" => "issue-comet", "action_id" => "issue_commented"}, #wrong
      ],
      "commit" => "Save changes"      
    }
        
    put :configuration_update, params

    assert_redirected_to gamification_configuration_url
    assert flash[:error].present?
    
    assert_equal 1, Gamification::UserToPlayer.count
    assert_equal [1], Gamification::UserToPlayer.where(player_id: "player1").pluck(:user_id)

    assert_equal 1, Gamification::EventToAction.count
    assert_equal 1, Gamification::EventToAction.for_issues.on_create.count
  end  

  def test_actions_for_nonadmin
    current_user_set_to(:player)
    get :actions
    assert_response :forbidden
  end

  def test_play_action_for_nonadmin
    current_user_set_to(:player)
    post :play_action, {action_id: 1}
    assert_response :forbidden
  end  

  def test_configuration_for_nonadmin
    current_user_set_to(:player)
    get :configuration
    assert_response  :forbidden
  end

  def test_configuration_update_for_nonadmin
    current_user_set_to(:player)
    put :configuration_update
    assert_response :forbidden
  end

  private
 
    def current_user_set_to(who)
      if who == :admin
        session[:user_id] = 1
      elsif who == :player
        session[:user_id] = @player.user_id
      elsif who.kind_of?(Integer)  
        session[:user_id] = who
      else
        raise "unknown WHO"  
      end  
    end  

   
    
    # def stub_game_with(s_game)
    #   @controller.game=s_game
    # end  


end
