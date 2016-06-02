require File.expand_path('../../test_helper', __FILE__)

class GamificationPlaylyfeRouteTest < ActionController::TestCase
  
  def test_default_page 
    assert_routing "/gamification", controller: "gamification", action: "index"
  end

  def test_player_page 
    assert_routing "/gamification/player/1", controller: "gamification", action: "player", id: "1"
  end

  def test_player_page 
    assert_routing "/gamification/my_scores", controller: "gamification", action: "my_scores"
  end

  def test_actions_page 
    assert_routing "/gamification/actions", controller: "gamification", action: "actions"
  end

  def test_play_action_page 
    assert_routing({ method: 'post', path: "/gamification/actions/action1/play"}, {controller: "gamification", action: "play_action", id: "action1"})
  end

  def test_leaderboards_page 
    assert_routing "/gamification/leaderboards", controller: "gamification", action: "leaderboards"
  end

  def test_configuration_page 
    assert_routing "/gamification/configuration", controller: "gamification", action: "configuration"
  end

  def test_play_action_page 
    assert_routing({ method: 'put', path: "/gamification/configuration"}, {controller: "gamification", action: "set_configuration"})
  end


  private

    def namespace_prefix
      "gamification"
    end  
end
