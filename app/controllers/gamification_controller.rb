class GamificationController < ApplicationController
  
  before_filter :require_player_or_admin  #, only: [:index, :leaderboards, :my_scores]
  before_filter :require_admin, except: [:index, :leaderboards, :my_scores]
  
  def index
    if params[:refresh_game]
      Gamification.game=nil #this will force refresh, otherwise game is chached only play_action is doing requests to Playlyfe API
    end  
    load_actions_and_game_players
  end
      
  def leaderboards
  end

  def my_scores
    @player=User.current.player
    render "player"
  end

  #admin actions
    
  def player
    redirect_to gamification_url unless set_player
  end

  def actions
    load_actions_and_game_players
    @player=no_player
  end

  def play_action
    if (set_player && set_action)
      @player.play(@action)
      flash[:notice] = t("gamification.play_action.action_successfully_played", action_id: @action.id, player_id: @player.id)
    end  
    
    load_actions_and_game_players
    @player=no_player if @player.blank?

    render "actions"
  end

  def configuration
    load_actions_and_game_players
    
    @users_to_players=Gamification::UserToPlayer.all.to_a
    5.times { @users_to_players << Gamification::UserToPlayer.new }
    @users=User.order("login ASC")
    
    @event_sources=Gamification::EventToAction.event_sources
    @event_names=Gamification::EventToAction.event_names
    @hooks_to_actions=Gamification::EventToAction.all
  end

  def configuration_update
    update_users_to_players if params["users_to_players"].present?
    update_events_to_actions
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
        flash[:error] = t("gamification.play_action.player_not_found", player_id: params[:player_id])
        return false
      else  
        return true
      end
    end   

    def set_action
      @action=game.actions.find(params[:action_id])
      if @action.blank?
        flash[:error] = t("gamification.play_action.action_not_found", action_id: params[:action_id])
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

    def update_users_to_players
      clean_u2ps=cleaned_u2ps.dup
      existing_u2ps=Gamification::UserToPlayer.all

      existing_u2ps.each do |ar_u2p|
        p_id=ar_u2p.player_id
        u_id=ar_u2p.user_id
        h={user_id: u_id, player_id: p_id}

        if clean_u2ps.include?(h)
          #no change here: leave it in DB, remove from params
          clean_u2ps.delete(h)
        else
          #is in DB but do not set in params => delete from DB
          ar_u2p.destroy
        end  
      end
      
      #there left only new records in clean_u2ps 
      clean_u2ps.each do |u_p|
        u2p=Gamification::UserToPlayer.new
        u2p.player_id=u_p[:player_id]
        u2p.user_id=u_p[:user_id]
        u2p.save!
      end

    end  

    def cleaned_u2ps
      u2ps=params[:users_to_players].select { |u2p| u2p[:user_id].to_i > 0 && (u2p[:player_id].present? && u2p[:player_id].to_s != "0") }
      u2ps.collect {|u2p| { user_id: u2p[:user_id].to_i, player_id: u2p[:player_id].to_s} }
    end    

    def update_events_to_actions
    end  

    def load_actions_and_game_players
      @actions=game.actions
      @game_players=game.players
    end  

    def no_player
      ::PlaylyfeClient::V2::Player.new({id: 0, alias: "----"},game)
    end  

end  

