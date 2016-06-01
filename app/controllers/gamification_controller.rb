class GamificationController < ApplicationController

  before_filter :set_game
  before_filter :manager_only, except: [:index, :leaderboards, :player]

  def index
  end
      
  def leaderboards
  end

  def player
     #find_player
     #check permission
  end

  #manager_only actions

  def actions

  end

  def play_action
    #find_player
    #play action  
    redirect_to gamification_actions_url
  end

  def configuration
  end

  def set_configuration
    #set config
    redirect_to gamification_configuration_url
  end  

  private

    def set_game
      # conn= ::PlaylyfeClient::V2::Connection.new(
      #   version: "v2",
      #   client_id: @settings["playlyfe_client_id"],
      #   client_secret: @settings["playlyfe_client_secret"],
      #   type: "client"
      #   )
      # @game=conn.game 
    end  

    def manager_only
    end  
end  

