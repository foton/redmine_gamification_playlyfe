module Gamification
  class HookToAction < ActiveRecord::Base
    self.table_name="hooks_to_actions"

    EVENT_SOURCE_ISSUE="issue"
    EVENT_SOURCES =[EVENT_SOURCE_ISSUE]
    EVENT_NAME_ON_CREATE ="create"
    EVENT_NAME_ON_STATUS_CHANGE ="status_change"
    EVENT_NAME_ON_UPDATE_WITHOUt_STATUS_CHANGE ="update_without_status_change"
    EVENT_NAME_ON_UPDATE ="update"
    EVENT_NAME_ON_CLOSE ="close"


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

    #procces all hooks attached to Issue events
    def self.process_issue(issue)
      HookToAction.for_issues.on_create
      # - Issue create, update, close (depending on tracker / Project)
      #- posts/journals create
    end  

    def play_action(player)
      player.play(action)
    end  

    scope :for_issues, -> { where(event_source: EVENT_SOURCE_ISSUE) }
    scope :on_create, -> { where(event_name: EVENT_NAME_ON_CREATE) }
    scope :on_status_change, -> { where(event_name: EVENT_NAME_ON_STATUS_CHANGE) }
    scope :on_update, -> { where(event_name: EVENT_NAME_ON_UPDATE) }
    scope :on_update_without_status_change, -> { where(event_name: EVENT_NAME_ON_UPDATE_WITHOUt_STATUS_CHANGE) }
    scope :on_close, -> { where(event_name: EVENT_NAME_ON_CLOSE) }

    private

      def action
        @action||=::Gamification.game.actions.find(self.action_id)
      end  
      

  end
end  
