module Gamification
  class HookToAction < ActiveRecord::Base
    self.table_name="hooks_to_actions"

    EVENT_SOURCE_ISSUE="issue"

    def self.event_sources
      @@event_sources ||= self.constants(false).select{|c| c=~/EVENT_SOURCE_.+/}.map{|c| self.module_eval c.to_s}.sort{|a,b| a<=>b}
    end
    
    EVENT_NAME_ON_CREATE ="create"
    EVENT_NAME_ON_STATUS_CHANGE ="status_change"
    EVENT_NAME_ON_OTHER_UPDATE ="other_update"
    EVENT_NAME_ON_COMMENT ="comment"
    EVENT_NAME_ON_CLOSE ="close"

    def self.event_names
      @@event_names ||= self.constants(false).select{|c| c=~/EVENT_NAME_.+/}.map{|c| self.module_eval c.to_s}.sort{|a,b| a<=>b}
    end



    def self.available_hooks
     #according to http://www.redmine.org/projects/redmine/wiki/Hooks_List
     list_redmine_hooks=`grep -roh  'call_hook(\:[^)]*)' | sort -u | grep '([^)]*)'`
     hooks=[]

     list_redmine_hooks.split("\n").each do |h|
        if m=h.match(/call_hook\(:(\w+), (.*)\)/)
          hooks<< [ m[1].to_sym, m[2]]
        end  
      end
      
      hooks
    end

    #process all hooks attached to Issue creation
    def self.process_created_issue(issue)
      if issue.author.player?
        HookToAction.for_issues.on_create.each {|h| h.play_action(issue.author.player)}
      end  
    end
      
    #process all hooks attached to Issue events, except :create
    def self.process_issue(issue)
      return if issue.created_on == issue.updated_on  #on creation  'create' AND 'save' events are triggered

      user=User.current

      if user.player?
        for scope in get_all_issue_event_scopes(issue)
          HookToAction.for_issues.send(scope).each {|h| h.play_action(user.player)} 
        end
      end  
    end  

    #comenting issue => creating journal with notes
    def self.process_commented_issue(journal)
      if journal.notes.strip.present? && !journal.private_notes?
        user=User.current
        if user.player?
          HookToAction.for_issues.on_comment.each {|h| h.play_action(user.player)}
        end  
      end 
    end  

    def play_action(player)
      player.play(action)
    end  

    scope :for_issues, -> { where(event_source: EVENT_SOURCE_ISSUE) }
    
    scope :on_create, -> { where(event_name: EVENT_NAME_ON_CREATE) }
    scope :on_status_change, -> { where(event_name: EVENT_NAME_ON_STATUS_CHANGE) }
    scope :on_comment, -> { where(event_name: EVENT_NAME_ON_COMMENT) }
    scope :on_other_update, -> { where(event_name: EVENT_NAME_ON_OTHER_UPDATE) }
    scope :on_close, -> { where(event_name: EVENT_NAME_ON_CLOSE) }

    private

      def action
        @action||=::Gamification.game.actions.find(self.action_id)
      end  
      
      #collect all event names to apply for issue change
      def self.get_all_issue_event_scopes(issue)
        changes_on=issue.changes.keys
     
        scope_names =[]
        #order of processing have matter!
        if changes_on.include?("status_id")
          if changes_on.include?("closed_on")
            scope_names << :on_close 
            changes_on.delete("closed_on")
          end  

          scope_names << :on_status_change
          changes_on.delete("status_id")
        end
        
        if changes_on.include?("status_id")
          scope_names << :on_comment
          changes_on.delete("status_id")
        end

        if (changes_on & ["description", "subject", "tracker_id", "priority_id", "project_id"]).present?
          scope_names <<  :on_other_update
        end  

        scope_names

      end
        
  end
end  
