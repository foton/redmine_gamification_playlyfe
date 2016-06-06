module Gamification
  module UserPatch

    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end
    
    
    module InstanceMethods
       
      def player
        @player||=get_player

      end

      def player?
        !player.blank?
      end
        
      def get_player
        p=Gamification::UserToPlayer.where(user_id: self.id).first  
        p=p.player unless p.blank?
        p
      end  
    end  
  end  
end  
