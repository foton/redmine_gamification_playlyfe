require File.expand_path('../../test_helper', __FILE__)

class GamificationControllerTest < ActionController::TestCase
  tests GamificationController
  fixtures :users

  def setup
    @user=User.find(2) 
    @player=Gamification::UserToPlayer.create!(user_id: @user.id, player_id: "player2")
    @game=fake_game
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
    get :player, {player_id: 6} #dlopper2
    assert_response :ok
    assert_template "gamification/player"
  end

  def test_player_for_nonadmin
    current_user_set_to(:player)
    get :player, {player_id: 6} #dlopper2
    assert_response :forbidden
  end

  def test_leaderboards
    current_user_set_to(:player)
    get :leaderboards
    assert_response :ok
    assert_template "gamification/leaderboards"
  end

  def test_actions_for_admin
    current_user_set_to(:admin)
    stub_game_with(@game)
    
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
    stub_game_with(@game)
    played_actions=@game.actions_played.size

    post :play_action, {action_id: "action1", player_id: "player1"}
    
    assert_response :ok
    assert_template "gamification/actions"
    assert_equal "Action 'action1' was successfully played by player 'player1", flash[:notice]
    assert flash[:error].blank?
    assert_equal played_actions+1, @game.actions_played.size
    assert_equal "action1", @game.actions_played.last
  end

  def test_play_action_with_no_player
    current_user_set_to(:admin)
    stub_game_with(@game)
    played_actions=@game.actions_played.size 

    post :play_action, {action_id: "action1", player_id: "player100"}
    assert_response :ok
    assert_template "gamification/actions"
    assert_equal "Player 'player100' not found!", flash[:error]
    assert_equal played_actions, @game.actions_played.size
  end

  def test_play_action_with_no_action
    current_user_set_to(:admin)
    stub_game_with(@game)
    played_actions=@game.actions_played.size
    
    post :play_action, {action_id: "action100", player_id: "player1"}
    assert_response :ok
    assert_template "gamification/actions"
    assert_equal "Action 'action100' not found!", flash[:error]
    assert_equal played_actions, @game.actions_played.size
  end

  def test_configuration_for_admin
    current_user_set_to(:admin)
    stub_game_with(@game)
 
    get :configuration
          
    assert_response :ok
    assert_template "gamification/configuration"
    
    assert assigns(:game_players).present?
    assert_equal @game.players.to_a.size, assigns(:game_players).to_a.size
    assert assigns(:users).present?
    assert_equal User.count, assigns(:users).size
    assert assigns(:users_to_players).present?
    assert_equal Gamification::UserToPlayer.count, assigns(:users_to_players).size

    assert assigns(:actions).present?
    assert_equal @game.actions.to_a.size, assigns(:actions).to_a.size
    assert assigns(:available_hooks).present?
    assert_equal Gamification::HookToAction.available_hooks.size, assigns(:available_hooks).size
    refute assigns(:hooks_to_actions).nil?
    assert_equal Gamification::HookToAction.all.size, assigns(:hooks_to_actions).size
  end

  def test_set_configuration_for_admin
    current_user_set_to(:admin)
    hook_name=Gamification::HookToAction.available_hooks.first.first
    action_1=@game.actions.to_a.first
    action_3=@game.actions.to_a.last

    put :set_configuration, {}, {hooks_actions: [[hook_name,action_1.id],[hook_name,action_3.id]]}
    assert_redirected_to gamification_configuration_url
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

  def test_set_configuration_for_nonadmin
    current_user_set_to(:player)
    put :set_configuration
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
