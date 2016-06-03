require File.expand_path('../../test_helper', __FILE__)

class GamificationIssueEventsProcessingTest < ActiveSupport::TestCase
  
   def setup
    @issue=Issue.first
   end 

   def test_on_create_event
    Issue.new
   end 


end
