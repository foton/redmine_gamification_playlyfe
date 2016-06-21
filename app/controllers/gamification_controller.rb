class GamificationController < ApplicationController
  
  before_filter :require_player_or_admin 
  before_filter :require_admin, except: [:index, :my_scores]
  
  def index
    @player=User.current.player #can be nil for admin!

    if params[:refresh_game]
      Gamification.game=nil #this will force refresh, otherwise game is chached only play_action is doing requests to Playlyfe API
    end  
    load_actions_and_game_players
    load_leaderboards
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
    status= :ok
    if (set_player && set_action)
      begin
        @player.play(@action)
        flash[:notice] = t("gamification.play_action.action_successfully_played", action_id: @action.id, player_id: @player.id)
      rescue PlaylyfeClient::Error => e
        flash[:error] = e.message
        status= :unprocessable_entity
      end  
    end  
    
    load_actions_and_game_players
    @player=no_player if @player.blank?

    render "actions", status: status
  end

  def configuration
    load_actions_and_game_players
    
    @users_to_players=Gamification::UserToPlayer.all.to_a
    5.times { @users_to_players << Gamification::UserToPlayer.new }
    @users=User.order("login ASC")
    
    @available_event_ids=Gamification::EventToAction.available_event_ids
    @events_to_actions=Gamification::EventToAction.all
    5.times { @events_to_actions << Gamification::EventToAction.new }
  end

  def configuration_update
    u2p_errors=[]
    e2a_errors=[]
    u2p_errors=update_users_to_players if params["users_to_players"].present?
    e2a_errors=update_events_to_actions if params["events_to_actions"].present?
    if u2p_errors.blank? && e2a_errors.blank?
      flash[:notice]=I18n.t("gamification.configuration.successfully_updated")
    else
      flash[:error]=(u2p_errors+e2a_errors).join("<br />")
    end  
    redirect_to gamification_configuration_url
  end  

  private

    def game
      begin
        @game||=Gamification.game
      rescue PlaylyfeClient::ConnectionError 
        flash[:error]="Your settings are not correct! No such client is recognized by Playlyfe.com"
        redirect_to plugin_settings_path(:redmine_gamification_playlyfe)
      end  
      @game
    end 
   
    def set_player
      @player=game.players.find(params[:player_id])
      if @player.blank?
        flash[:error] = t("gamification.user_to_player.errors.player_is_not_in_game", player_id: params[:player_id])
        return false
      else  
        return true
      end
    end   

    def set_action
      @action=game.actions.find(params[:action_id])
      if @action.blank?
        flash[:error] = t("gamification.event_to_action.errors.action_is_not_in_game", action_id: params[:action_id])
        return false
      else  
        return true
      end
    end  

    def require_player_or_admin
      return unless require_login
      game #to raise error if client cannot connect to Playlyfe game 
      if (User.current.admin? || User.current.player?)
        return true
      else  
        render_403
        return false
      end
    end

    def update_users_to_players
      errors=[]
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
        unless u2p.save
          errors << I18n.t("gamification.user_to_player.errors.error_on_creating", user_id: u2p.user_id, player_id: u2p.player_id, errors: u2p.errors.full_messages.join("; "))
        end 
      end
      errors
    end  

    def cleaned_u2ps
      u2ps=params[:users_to_players].select { |u2p| u2p[:user_id].to_i > 0 && (u2p[:player_id].present? && u2p[:player_id].to_s != "0") }
      u2ps.collect {|u2p| { user_id: u2p[:user_id].to_i, player_id: u2p[:player_id].to_s} }
    end    

    def update_events_to_actions
      errors=[]
      clean_e2as=cleaned_e2as.dup
      existing_e2as=Gamification::EventToAction.all

      existing_e2as.each do |ar_e2a|
        h={event_id: ar_e2a.event_id, action_id: ar_e2a.action_id}

        if clean_e2as.include?(h)
          #no change here: leave it in DB, remove from params
          clean_e2as.delete(h)
        else
          #is in DB but do not set in params => delete from DB
          ar_e2a.destroy
        end  
      end
      
      #there left only new records in clean_e2as 
      clean_e2as.each do |u_p|
        e2a=Gamification::EventToAction.new
        e2a.event_id=u_p[:event_id]
        e2a.action_id=u_p[:action_id]
        unless e2a.save
          errors << I18n.t("gamification.event_to_action.errors.error_on_creating", event_id: e2a.event_id, action_id: e2a.action_id, errors: e2a.errors.full_messages.join("; "))
        end  
      end
      errors
    end  

    def cleaned_e2as
      e2as=params[:events_to_actions].select { |e2a| e2a[:action_id].present? && e2a[:event_id].present? }
      e2as.collect {|e2a| { event_id: e2a[:event_id].to_s, action_id: e2a[:action_id].to_s} }
    end 

    def load_actions_and_game_players
      @actions||=game.actions
      @game_players||=game.players
    end  

    def load_leaderboards
      @leaderboards||=game.leaderboards
    end  

    def no_player
      ::PlaylyfeClient::V2::Player.new({id: 0, alias: "----"},game)
    end  

end  

