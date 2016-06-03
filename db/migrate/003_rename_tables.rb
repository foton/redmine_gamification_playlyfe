class RenameTables < ActiveRecord::Migration
  def change
    rename_table :players, :users_to_players
    rename_table :hook_to_actions, :hooks_to_actions
  end
end
