module Gamification
  class UserToPlayer < ActiveRecord::Base
    has_many :users #many users can be linked to one player

  end
end  
