require File.expand_path('../../test_helper', __FILE__)

class GamificationRouteTest < ActionController::TestCase
  
  def test_default_page 
    assert_routing "/gamification", controller: "gamification", action: "index"
  end

  def test_player_page 
    assert_routing "/gamification/player/1", controller: "gamification", action: "player", player_id: "1"
  end

  def test_player_page 
    assert_routing "/gamification/my_scores", controller: "gamification", action: "my_scores"
  end

  def test_actions_page 
    assert_routing "/gamification/actions", controller: "gamification", action: "actions"
  end

  def test_play_action_page 
    assert_routing({ method: 'post', path: "/gamification/actions/action1/play"}, {controller: "gamification", action: "play_action", action_id: "action1"})
  end

  def test_configuration_page 
    assert_routing "/gamification/configuration", controller: "gamification", action: "configuration"
  end

  def test_play_action_page 
    assert_routing({ method: 'put', path: "/gamification/configuration"}, {controller: "gamification", action: "configuration_update"})
  end


  private

    def namespace_prefix
      "gamification"
    end  
end
