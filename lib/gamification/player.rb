module Gamification
  class Player < ActiveRecord::Base
    has_many :users
    
  end
end  
