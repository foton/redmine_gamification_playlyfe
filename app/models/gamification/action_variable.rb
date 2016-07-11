module Gamification
  #this is used for defining way how to fill Playlyfe Action variables before call to Playlyfe API
  class ActionVariable < ActiveRecord::Base
    self.table_name="gamification_action_variables"
  end
end    
