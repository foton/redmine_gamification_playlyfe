module Gamification
  class Playlyfe

    def self.game
      unless defined?(@game)
        puts("connecting_to_playlyfe")
        settings=Setting.plugin_redmine_gamification_playlyfe
        conn= ::PlaylyfeClient::V2::Connection.new(
          version: "v2",
          client_id: settings["playlyfe_client_id"],
          client_secret: settings["playlyfe_client_secret"],
          type: "client"
          )
        @game=conn.game 
      end
      @game
    end 

  end  
  
end    
