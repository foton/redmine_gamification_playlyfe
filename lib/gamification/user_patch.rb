module Gamification
  module UserPatch
    def self.apply
      User.class_eval do
        include InstanceMethods
      end unless User < InstanceMethods # no need to do this more than once.
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
