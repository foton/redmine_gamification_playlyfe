module Gamification
  class HookToAction < ActiveRecord::Base
    self.table_name="hooks_to_actions"

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
      
  end
end  
