module Gamification
  module UserPatch

    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end
    
    
    module InstanceMethods
       
      def player
        Gamification::UserToPlayer.where(user_id: self.id).first
      end

      def player?
        !player.blank?
      end
        
    end  
  end  
end  
