#require_dependency 'redmine_gamification_playlyfe'

Redmine::Plugin.register :redmine_gamification_playlyfe do
  name 'Plugin for gamification using Playlyfe service'
  url 'https://github.com/foton/redmine_gamification_playlyfe'
  author_url 'https://github.com/foton'
  author 'Foton'
  description "This is a plugin for Redmine, which let you link users, actions and events in Redmine to Playlyfe game.
               You set your game (rules, actions, rewards ...) at Playlyfe and setup Redmine to use it's actions.
               So adding comment or closing issue can be rewarded."
  version '0.0.1'
  requires_redmine version_or_higher: '3.1.1'

  #permission :redmine_gamification_plugin, {:redmine_gamification_plugin => [:project]}, :public => true

  menu :top_menu, :redmine_gamification_playlyfe, {controller: 'gamification', action: 'index'}, :caption => I18n.t("gamification.plugin_name")
 # menu :project_menu, :project_gamification, {controller: 'gamification', action: 'project'}, caption: 'Status', param: :project_id 
  
  #permission :view_scores, { :gamification => [:index, :leaderboards, :my] }, :require => :loggedin
  #permission :view_scores_of_others, { :gamification => [:player] }, :require => :loggedin
  #permission :direct_play_action, { :gamification => [:actions, :play_action] }, :require => :loggedin
  #permission :configure, { :gamification => [:configuration, :set_configuration] }, :require => :loggedin
    

  settings partial: 'settings/redmine_gamification_playlyfe', default: {}


  #http://www.redmine.org/projects/redmine/wiki/Plugin_Tutorial#Extending-the-application-menu
end

 Rails.configuration.to_prepare do
   Gamification.setup
 end
