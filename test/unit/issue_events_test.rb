require File.expand_path('../../test_helper', __FILE__)

class GamificationIssueEventsProcessingTest < ActiveSupport::TestCase
   fixtures_for_creating_issues
  
   def setup
    @issue=Issue.first
   end 

   def test_attached_callbacks
     issue=create_issue
     # after_create :process_gamification_on_create  should be called
     issue.subject="fffffff"
     issue.save!
     # after_save :process_gamification_on_save
   end 




end
