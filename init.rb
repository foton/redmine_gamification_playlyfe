#require_dependency 'redmine_gamification_playlyfe'

#developed with big help form
#https://jkraemer.net/2015/11/how-to-create-a-redmine-plugin
#http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial#Extending-the-application-menu
#https://github.com/edavis10/redmine_kanban

require 'redmine'

# Patches to the Redmine core.
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'issue'
  # Guards against including the module multiple time (like in tests)
  # and registering multiple callbacks
  unless Issue.included_modules.include? Gamification::IssuePatch
    Issue.send(:include, Gamification::IssuePatch)
  end

  unless Journal.included_modules.include? Gamification::JournalPatch
    Journal.send(:include, Gamification::JournalPatch)
  end

  unless User.included_modules.include? Gamification::UserPatch
    User.send(:include, Gamification::UserPatch)
  end

end



Redmine::Plugin.register :redmine_gamification_playlyfe do
  name 'Plugin for gamification using Playlyfe service'
  url 'https://github.com/foton/redmine_gamification_playlyfe'
  author_url 'https://github.com/foton'
  author 'Foton'
  description "This is a plugin for Redmine, which let you link users, actions and events in Redmine to Playlyfe game.
               You set your game (rules, actions, rewards ...) at Playlyfe and setup Redmine to use it's actions.
               So adding comment or closing issue can be rewarded."
  version '1.0.0'
  requires_redmine version_or_higher: '3.1.1'

  #permission :redmine_gamification_plugin, {:redmine_gamification_plugin => [:project]}, :public => true

  menu :top_menu, :redmine_gamification_playlyfe, {controller: 'gamification', action: 'index'}, :caption => "gamification.menu_title".to_sym
 # menu :project_menu, :project_gamification, {controller: 'gamification', action: 'project'}, caption: 'Status', param: :project_id 
  
  #permission :view_scores, { :gamification => [:index, :leaderboards, :my] }, :require => :loggedin
  #permission :view_scores_of_others, { :gamification => [:player] }, :require => :loggedin
  #permission :direct_play_action, { :gamification => [:actions, :play_action] }, :require => :loggedin
  #permission :configure, { :gamification => [:configuration, :configuration_update] }, :require => :loggedin
    
  settings partial: 'settings/redmine_gamification_playlyfe', default: {}
end

 
