class RenameTablesWithPrefixGamification < ActiveRecord::Migration
  def change
    rename_table :events_to_actions, :gamification_events_to_actions
    rename_table :users_to_players, :gamification_users_to_players
  end
end
