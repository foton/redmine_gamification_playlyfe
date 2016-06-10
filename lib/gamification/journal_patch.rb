module Gamification
  module JournalPatch

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
            
        after_create :process_gamification_on_create

        # Add visible to Redmine 0.8.x
        # unless respond_to?(:visible)
        #   named_scope :visible, lambda {|*args| { :include => :project,
        #       :conditions => Project.allowed_to_condition(args.first || User.current, :view_issues) } }
        # end
      end

    end
    
    module ClassMethods
    end
    
    module InstanceMethods
       
      def process_gamification_on_create
        Gamification::EventToAction.process_commented_issue(self)
      end
        
      private :process_gamification_on_create  
    end  
  end  
end  
