module Gamification
  #this is used for defining way how to fill Playlyfe Action variables before call to Playlyfe API
  class ActionVariable < ActiveRecord::Base
    self.table_name="gamification_action_variables"

    validate :av_validation
    def av_validation
      a=Gamification.game.actions.find(self.action_id)
      if a.nil?
        self.errors.add(:action_id, I18n.t("gamification.action_variable.errors.action_was_not_found", action_id: self.action_id))
      else
        av=a.variables.detect {|v| self.variable == v["name"] }
        if av.nil?
          self.errors.add(:variable, I18n.t("gamification.action_variable.errors.variable_was_not_found", action_id: self.action_id, variable: variable))
        else
          if (self.eval_string.nil? || self.eval_string == "")
            self.errors.add(:eval_string, I18n.t("gamification.action_variable.errors.eval_string_is_empty", action_id: self.action_id, variable: variable, eval_string: eval_string))
          else
            [Issue.first, Issue.last].each do |issue|
              begin
                result=eval(self.eval_string)
              rescue Exception => exc #there must be Exception catch, see http://stackoverflow.com/questions/542845/how-to-rescue-an-eval-in-ruby
                self.errors.add(:eval_string, I18n.t("gamification.action_variable.errors.eval_string_is_wrong", action_id: self.action_id, variable: variable, eval_string: eval_string, issue_id: issue.id))                
              end  
              
              #eval is ok, but what about the result?
              if (av["type"] == "string" && !result.kind_of?(String)) || (av["type"] == "int" && !result.kind_of?(Integer) )
                self.errors.add(:eval_string, I18n.t("gamification.action_variable.errors.eval_string_returning_wrong_type", action_id: self.action_id, variable: variable, eval_string: eval_string, issue_id: issue.id, type: av["type"], result: result))                
              end                
            end  
          end  

        end
      end

    end      

  end
end    
