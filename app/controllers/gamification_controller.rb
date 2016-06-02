class GamificationController < ApplicationController
  
  before_filter :require_player_or_admin  #, only: [:index, :leaderboards, :my_scores]
  before_filter :require_admin, except: [:index, :leaderboards, :my_scores]

  before_filter :set_game

  def index
  end
      
  def leaderboards
  end

  def my_scores
    #@player=Player.find(User.current.id)
    render "player"
  end
    
  def player
     #find_player
     #@player=Player.find(params[:id].to_i)
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

    def game
      @game 
    end  

    def require_player_or_admin
      return unless require_login
      if User.current.admin? || User.current.player?
        return true
      else  
        render_403
        return false
      end
    end

end  

