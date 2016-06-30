module Gamification
  class Playlyfe

    def self.game
      puts("connecting_to_playlyfe")
      settings=Setting.plugin_redmine_gamification_playlyfe
      conn= ::PlaylyfeClient::V2::Connection.new(
        version: "v2",
        client_id: settings["playlyfe_client_id"],
        client_secret: settings["playlyfe_client_secret"],
        type: "client",
        skip_api_calls_limit_exceeded_error: (settings["playlyfe_client_skip_api_calls_limit_exceeded_error"].to_i == 1)
        )
      conn.game 
    end 

  end  
  
end    
