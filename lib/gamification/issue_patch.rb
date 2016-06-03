module Gamification
  module IssuePatch
    #inspiration https://github.com/edavis10/redmine_kanban/blob/000cf175795c18033caa43082c4e4d0a9f989623/lib/redmine_kanban/issue_patch.rb#L13

    def self.included(base) # :nodoc:
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)

      # Same as typing in the class 
      base.class_eval do
            
        after_save :process_gamification_on_save
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
       
      def process_gamification_on_save
        puts("process_gamification_on_save")
        Gamification::HookToAction.process_issue(self)
      end

      def process_gamification_on_create
        puts("process_gamification_on_create")
        Gamification::HookToAction.process_created_issue(self)
      end
        
      private :process_gamification_on_save
      private :process_gamification_on_create  
    end  
  end  
end  
