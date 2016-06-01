require File.expand_path('../../test_helper', __FILE__)

class GamificationControllerTest < ActionController::TestCase
  tests GamificationController
  
  def test_index
    get :index
    assert_response :ok
    assert_template "gamification/index"
  end
    

  def test_player
    get :player, {id: 1}
    assert_response :ok
    assert_template "gamification/player"
  end

  def test_leaderboards
    get :leaderboards
    assert_response :ok
    assert_template "gamification/leaderboards"
  end

  def test_actions
    get :actions
    assert_response :ok
    assert_template "gamification/actions"
  end

  def test_play_action
    post :play_action, {id: "action1"}
    assert_redirected_to gamification_actions_url
  end

  def test_configuration
    get :configuration
    assert_response :ok
    assert_template "gamification/configuration"
  end

  def test_set_configuration
    put :set_configuration
    assert_redirected_to gamification_configuration_url
  end

end
