module GamificationHelper
  def rewards_to_s_for_action(action)
    rewards=action.rewards.collect do |rwd|
      metric_name= rwd[:metric].name
      change_value=rwd[:value]
      change_to_s=(rwd[:verb] == "add" ? "+= #{change_value}" : (rwd[:verb] == "remove" ? "-= #{change_value}" : " = #{change_value}"))
      if  rwd[:probability].to_i != 1
        nil # we show only 100% rewards
      else  
        "#{metric_name} #{change_to_s}"
      end  
    end  

    rewards.compact
  end  

  def all_users_for_player(player)
    Gamification::UserToPlayer.where(player_id: player.id).collect {|up| up.user.login}
  end 

  def options_for_user_select(user_id)
    options_for_select( ([["--",0]]+ @users.to_a.collect {|u| ["#{u.login} - #{u.name} ", u.id]}), user_id)
  end

  def options_for_player_select(player_id)
    options_for_select( ([["--",0]]+ @game_players.to_a.collect {|p| [p.name, p.id]}), player_id)
  end 
end
