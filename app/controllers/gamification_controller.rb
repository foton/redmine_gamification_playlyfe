class GamificationController < ApplicationController
  
  before_filter :require_player_or_admin  #, only: [:index, :leaderboards, :my_scores]
  before_filter :require_admin, except: [:index, :leaderboards, :my_scores]
  
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
    @actions=game.actions
    @game_players=game.players
  end

  def play_action
    if (set_player && set_action)
      @player.play(@action)
      flash[:notice] = "Action '#{@action.id}' was successfully played by player '#{@player.id}"
    end  
    render "actions"
  end

  def configuration
    @game_players=game.players
    @users_to_players=Gamification::UserToPlayer.all
    @users=User.all

    @actions=game.actions
    @available_hooks=Gamification::HookToAction.available_hooks
    @hooks_to_actions=Gamification::HookToAction.all
  end

  def set_configuration
    update_configuration
    flash[:notice]="Configuration updated"
    redirect_to gamification_configuration_url
  end  

  private

    def game
      @game||=Gamification.game
    end 
   
    def set_player
      @player=game.players.find(params[:player_id])
      if @player.blank?
        flash[:error]="Player '#{params[:player_id]}' not found!"
        return false
      else  
        return true
      end
    end   

    def set_action
      @action=game.actions.find(params[:action_id])
      if @action.blank?
        flash[:error]="Action '#{params[:action_id]}' not found!"
        return false
      else  
        return true
      end
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

    def update_configuration
    end  

end  

