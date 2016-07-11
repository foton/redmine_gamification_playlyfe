module Gamification
  class UserToPlayer < ActiveRecord::Base
    self.table_name="gamification_users_to_players"
   
    belongs_to :user, class_name: User

    validate :validate_player_id
    validates :user, presence: true

    def player
      @player||=Gamification.game.players.find(self.player_id)
    end

    private
      def validate_player_id
        if self.player_id.blank? || !( (Gamification.game.players.to_a.collect {|p| p.id}).include?(self.player_id))
          self.errors.add(:player_id, I18n.t("gamification.user_to_player.errors.player_is_not_in_game", player_id: self.player_id) )
        end  
      end    
  end
end  



module PlaylyfeClient
  class Player 
    def users
      User.find(Gamification::UserToPlayer.where(player_id: self.id).pluck(:user_id))
    end
    
  end  
end    
