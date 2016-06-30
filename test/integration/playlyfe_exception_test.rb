require File.expand_path('../../test_helper', __FILE__)

class PlaylyfeExceptionTest < ActionController::TestCase

  def test_not_blocks_redmine_when_api_calls_limit_reached
    skip #TODO: if 'Silently skip over API Calls Limit Exceeded Error' in config is checked, than any crashing API call with 'plan_limit_exceeded' is returned mercifully with blank array, hash and so on.
    #so no impact to Redmine, just Gamification will be (temporarily) blank  

  end  

end  
