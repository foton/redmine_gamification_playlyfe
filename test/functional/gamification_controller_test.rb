require File.expand_path('../../test_helper', __FILE__)

class GamificationControllerTest < ActionController::TestCase
  tests GamificationController
  fixtures :users

  def setup
    @user=User.find(2) 
    @player=Gamification::Player.create!(user_id: @user.id, player_id: "player2")
  end  

  def test_index
    current_user_set_to(:player)
    get :index
    #assert_response :ok
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
    get :player, {id: 6} #dlopper2
    assert_response :ok
    assert_template "gamification/player"
  end

  def test_player_for_nonadmin
    current_user_set_to(:player)
    get :player, {id: 6} #dlopper2
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
    get :actions
    assert_response :ok
    assert_template "gamification/actions"
  end

  def test_play_action_for_admin
    current_user_set_to(:admin)
    post :play_action, {id: "action1"}
    assert_redirected_to gamification_actions_url
  end

  def test_configuration_for_admin
    current_user_set_to(:admin)
    get :configuration
    assert_response :ok
    assert_template "gamification/configuration"
  end

  def test_set_configuration_for_admin
    current_user_set_to(:admin)
    put :set_configuration
    assert_redirected_to gamification_configuration_url
  end

  def test_actions_for_nonadmin
    current_user_set_to(:player)
    get :actions
    assert_response :forbidden
  end

  def test_play_action_for_nonadmin
    current_user_set_to(:player)
    post :play_action, {id: "action1"}
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


  def current_user_set_to(who)
    if who == :admin
      session[:user_id] = 1
    elsif who == :player
      session[:user_id] = 2  
    elsif who.kind_of?(Integer)  
      session[:user_id] = who
    else
      raise "unknown WHO"  
    end  
  end  

end
