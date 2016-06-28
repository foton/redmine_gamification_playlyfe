module GamificationHelper
  def rewards_to_s_for_action(action)
    rewards=action.rewards.collect do |rwd|
      metric_name= rwd[:metric].name
      change_value=rwd[:value]
      change_to_s=(rwd[:verb] == "add" ? "+= #{change_value}" : (rwd[:verb] == "remove" ? "-= #{change_value}" : " = #{change_value}"))
      if  rwd[:probability].to_i != 1
        nil # we show only 100% rewards
      else  
        " #{metric_name} #{change_to_s} "
      end  
    end  

    rewards.compact
  end  

  def player_to_link(pl)
    if User.current.admin?
      plink=link_to( pl.name, gamification_player_url(player_id: pl.id))
    elsif User.current.player? && User.current.player.id == pl.id 
      plink=link_to(pl.name, gamification_my_scores_url)
    else
      plink=pl.name.html_safe
    end   
    plink+="<span class=\"states\"></span>".html_safe
    plink+="<span class=\"sets\"></span>".html_safe
    plink
  end       

  def all_users_for_player(player)
    Gamification::UserToPlayer.where(player_id: player.id).collect {|up| up.user.login}
  end 

  def options_for_user_select(user_id)
    options_for_select( ([["-not used-",0]]+ @users.to_a.collect {|u| ["#{u.login} (#{u.name})", u.id]}), user_id)
    #options_for_select([["one",1],["two",2]])
  end

  def options_for_player_select(player_id)
    options_for_select( ([["-not used-",0]]+ @game_players.to_a.collect {|p| ["#{p.id} (#{p.name})", p.id]}), player_id)
    #options_for_select([["one",1],["two",2]])
  end 

  def options_for_event_select(event_id)
    options_for_select( ([["-not used-","-"]]+ @available_event_ids.to_a.collect {|e_id| [e_id, e_id]}), (event_id || "") )
  end 

  def options_for_action_select(action_id)
    options_for_select( ([["-not used-",""]]+ @actions.to_a.collect {|a| [a.name, a.id]}), (action_id || "") )
  end 

  def show_team(team)
    content_tag(:li) do 
      concat content_tag(:span, class: "team_name") { team.name }
      concat (team.members.collect {|tm| tm.name}).join(", ")
    end
  end

  def show_position(pos, current_player)
    return "" if pos.blank? || !pos.kind_of?(Array)
    
    if pos.first[:entity].kind_of?(PlaylyfeClient::Team)
      show_position_for_teams(pos, current_player)
    else
      show_position_for_players(pos, current_player)
    end  
  end
  
  def show_position_for_players(pos, current_player)  
    entities=[]
    
    pos.each do |p|
      entity=p[:entity]
      entities << ( (current_player && (current_player.id == entity.id)) ? "<strong>#{entity.name}</strong>" : "#{entity.name}" )
    end
      
    score=pos.first[:score]
    "#{entities.join("; ")} [#{score}]".html_safe
  end  

  def show_position_for_teams(pos, current_player)
    entities=[]
    score=pos.first[:score]

    pos.each do |p|
      entity=p[:entity]
      e_name= "#{entity.name} [#{average_on_player(entity, score)}]"
      entities << ( (current_player && current_player.teams.collect {|t| t.id}.include?(entity.id)) ? "<strong>#{e_name}</strong>" : "#{e_name}" )
    end
    
    "#{entities.join("; ")} [#{score}]".html_safe
  end  

  def average_on_player(team, score)
    average=(team.members.size == 0 ? 0 : score.to_i/team.members.size)
    "#{t("gamification.scores.average_on_player")}: #{average}"
  end
    
  def admin_area &block
    if User.current.admin?
      yield
    end  
  end  


end
