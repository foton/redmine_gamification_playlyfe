module Gamification

  def self.game
    @@game||=Gamification::Playlyfe.game
  end   
  
  #for test stubbing and forcing refresh
  def self.game=(game)
    @@game=game
  end 
end    
