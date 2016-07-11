module Gamification
  class EventToAction < ActiveRecord::Base
    self.table_name="gamification_events_to_actions"

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

    validate :validate_event_id
    validate :validate_action_id
    #validates :action, presence: true, inclusion: { in: (Gamification.game.actions.collect {|a| a.id}) , message: I18n.t("gamification.event_to_action.action_is_not_in_game", action_id: value) }    

    def <=>(other)
      r=(self.event_source <=>  other.event_source)
      return r if r != 0
      r=(self.event_name <=>  other.event_name)
      return r if r != 0
      return (self.action_id <=>  other.action_id)
    end  

    def event_id
      @event_id||=(self.event_source.to_s+"-"+self.event_name.to_s)
    end  

    def event_id=(ev_id)
      self.event_source, self.event_name = ev_id.split("-")
      @event_id=ev_id
    end  

    
    
    #combination of event sources and event names  which are allowed to use
    def self.available_event_ids
      unless defined? @available_event_ids
        @available_event_ids=[]
        @available_event_ids << self.new({ event_source: EVENT_SOURCE_ISSUE, event_name: EVENT_NAME_ON_CREATE }).event_id
        @available_event_ids << self.new({ event_source: EVENT_SOURCE_ISSUE, event_name: EVENT_NAME_ON_STATUS_CHANGE }).event_id
        @available_event_ids << self.new({ event_source: EVENT_SOURCE_ISSUE, event_name: EVENT_NAME_ON_OTHER_UPDATE }).event_id
        @available_event_ids << self.new({ event_source: EVENT_SOURCE_ISSUE, event_name: EVENT_NAME_ON_COMMENT }).event_id
        @available_event_ids << self.new({ event_source: EVENT_SOURCE_ISSUE, event_name: EVENT_NAME_ON_CLOSE }).event_id

        @available_event_ids.sort!
      end  
      @available_event_ids  
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
        EventToAction.for_issues.on_create.each {|h| h.play_action(issue.author.player)}
      end  
    end
      
    #process all hooks attached to Issue events, except :create
    def self.process_issue(issue)
      return if issue.created_on == issue.updated_on  #on creation  'create' AND 'save' events are triggered

      user=User.current

      if user.player?
        for scope in get_all_issue_event_scopes(issue)
          EventToAction.for_issues.send(scope).each {|h| h.play_action(user.player)} 
        end
      elsif issue.assigned_to.kind_of?(User) && issue.assigned_to.player? 
        #if issue is closed by nonplayer and assignet to player, then actions are played on behalf assigned_to user
        for scope in (get_all_issue_event_scopes(issue) & [:on_close]) #on close only is this rule applied
          EventToAction.for_issues.send(scope).each {|h| h.play_action(issue.assigned_to.player)} 
        end
      end  
    end  

    #comenting issue => creating journal with notes
    def self.process_commented_issue(journal)
      if journal.notes.to_s.strip.present? && !journal.private_notes?
        user=User.current
        if user.player?
          EventToAction.for_issues.on_comment.each {|h| h.play_action(user.player)}
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

      def validate_event_id
        unless Gamification::EventToAction.available_event_ids.include?(self.event_id)
          self.errors.add(:event_source, I18n.t("gamification.event_to_action.errors.event_id_is_not_available", event_id: self.event_id))
          self.errors.add(:event_name, I18n.t("gamification.event_to_action.errors.event_id_is_not_available", event_id: self.event_id))
        end  
      end

      def validate_action_id
        if self.action_id.blank? || !( (Gamification.game.actions.to_a.collect {|a| a.id}).include?(self.action_id))
          self.errors.add(:action_id, I18n.t("gamification.event_to_action.errors.action_is_not_in_game", action_id: self.action_id) )
        end  
      end      

      def action
        @action||=::Gamification.game.actions.find(self.action_id)
      end  
      
      #collect all event names to apply for issue change
      def self.get_all_issue_event_scopes(issue)
        changes_on=issue.saved_changes.keys
     
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
