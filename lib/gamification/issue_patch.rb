module Gamification
  module IssuePatch
    def self.apply
      Issue.class_eval do
        # using prepend instead of include makes life much easier when you have
        # to override already existing methods. Death to alias_method_chain!
        prepend InstanceMethods
        after_save :process_gamification
      end unless Issue < InstanceMethods # no need to do this more than once.
    end  

    module InstanceMethods

      def process_gamification
        Gamification::HookToAction.process_issue(self)
      end
        
    end  
  end  
end  
