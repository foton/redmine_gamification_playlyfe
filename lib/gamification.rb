module Gamification
  def self.setup
    UserPatch.apply
  end  

  def self.game
    @game||=Gamification::Playlyfe.game
  end   
  
  #for test stubbing 
  def self.game=(game)
    @game=game
  end 
end    
