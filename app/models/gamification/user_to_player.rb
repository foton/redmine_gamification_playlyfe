module Gamification
  class UserToPlayer < ActiveRecord::Base
    self.table_name="users_to_players"

    def player
      @player||=Gamification.game.players.find(self.player_id)
    end
    
    def user
      @user||=User.find(self.user_id)
    end  
  end
end  
