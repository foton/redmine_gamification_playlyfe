#RUN SINGLE TEST?  
#rake test TEST=test/models/identity_test.rb TESTOPTS="--name=test_can_be_created_from_auth_without_user -v"

#RUN ALL TESTS IN FILE?
#rake test TEST=test/models/identity_test.rb 

require "minitest/reporters"
require_relative "./rake_rerun_reporter.rb"
require 'minitest/autorun'

reporter_options = { color: true, slow_count: 5, verbose: false, rerun_prefix: "NAME=redmine_gamification_playlyfe bundle exec bin/rake redmine:plugins:test" }
#Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(reporter_options)]
Minitest::Reporters.use! [Minitest::Reporters::RakeRerunReporter.new(reporter_options)]

# Load the Redmine helper
require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')






def stub_game_with(game)
  Gamification.game=game
end  

Struct.new("Player", :id, :name, :game ) do
  def play(action,variables={})
    game.action_played(action.id, self.id, variables)
    true
  end  

  def scores(reload=false)
    { points: { a: 1 , b: 2}, 
      sets: { toolbox: [{ name: "hammer", count: 1}, {name: "screwdriver", count: 2}]},
      states: { rank: "Private"},
      compounds: {}
    }
  end  

  def events(start_time=nil, end_time=nil)
    []
  end  
end  

Struct.new("Team", :id, :name, :game, :members ) do
  def events(start_time=nil, end_time=nil)
    []
  end  
end  


Struct.new("Action", :id, :name, :game) do
  def rewards
    []
  end

  def variables
    []
  end  
end

Struct.new("ActionWithVariables", :id, :name, :game, :variables) do
  def rewards
    []
  end
end

Struct.new("Collection", :to_a) do
  def find(id)
    to_a.detect {|item| item.id == id}
  end  

  def for_teams
    for_what(:teams)
  end
  
  def for_players
    for_what(:players)
  end  

  def for_what(what)
    to_a.select {|item| (item.respond_to?(:for) && item.for == what) }
  end 
end

Struct.new("Game", :title, :players, :actions, :leaderboards, :teams) do

  def variables_passed
    @variables_passed||=[]
  end
    
  def actions_played
    @actions_played||=[]
  end
  
  def action_played(action_id, player_id, variables)
    actions_played << [action_id, player_id]
    variables_passed << variables unless variables.empty?
  end

  def events(start_time=nil, end_time=nil)
    []
  end  
end  


def fake_game
  unless defined?(@fake_game)

    @fake_game = Struct::Game.new("test_game", [] , [], [])

    @fake_game.actions=Struct::Collection.new([
      Struct::Action.new("issue_created", "Issue created", @fake_game),
      Struct::Action.new("issue_commented", "Issue commented", @fake_game),
      Struct::Action.new("issue_definition_updated", "Issue title od description updated", @fake_game),
      Struct::Action.new("issue_status_change", "Isssue status change", @fake_game),
      Struct::Action.new("issue_code_review_done", "Issue CR done", @fake_game),
      Struct::Action.new("issue_closed", "Issue closed", @fake_game),
      Struct::Action.new("wiki_updated", "Wiki update", @fake_game),
      Struct::Action.new("commit_to_repo", "Commit to repository", @fake_game),
      Struct::ActionWithVariables.new("set_a_and_b_to", "Set A and B to new values", @fake_game, [
                                                                                                    { "default" => 2,
                                                                                                      "name" => "a_var_int",
                                                                                                      "required" => true,
                                                                                                      "type" => "int"
                                                                                                    },
                                                                                                    {
                                                                                                      "default" => "default",
                                                                                                    "name" => "b_var_str",
                                                                                                    "required" => false,
                                                                                                    "type" => "string"
                                                                                                    }

                                                                                                  ]),
    ])

    p1=Struct::Player.new("player1", "Player 1", @fake_game)
    p2=Struct::Player.new("player2", "Player 2", @fake_game)
    p3=Struct::Player.new("player3", "Player 3", @fake_game)

    @fake_game.players=Struct::Collection.new([p1,p2,p3])

    @fake_game.teams=Struct::Collection.new([
      Struct::Team.new("team1", "Team 1", @fake_game, [p1,p2]),
      Struct::Team.new("team2", "Team 2", @fake_game, []),
      Struct::Team.new("team3", "Team 3", @fake_game, [p3,p1]),
    ])

    @fake_game.leaderboards=Struct::Collection.new([])
    
  end
  @fake_game  
end


def   fixtures_for_creating_issues
  fixtures :projects, :issues, :users,
    :members, :member_roles, :roles, :trackers, :projects_trackers,
    :issue_statuses, :enumerations
end

def player
  @player
end  

def create_player(user, player_id)
  Gamification::UserToPlayer.create!(user_id: user.id, player_id: player_id)
  @player=user
end  

def create_issue
  Issue.create!(:project_id => 1, :tracker_id => 1, :author_id => player.id,
                      :status_id => 1, :priority => IssuePriority.all.first,
                      :subject => 'test_create',
                      :description => 'IssueTest#test_create', :estimated_hours => '1:30')
end  

