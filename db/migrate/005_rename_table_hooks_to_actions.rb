class RenameTableHooksToActions < ActiveRecord::Migration
  def change
    rename_table :hooks_to_actions, :events_to_actions
  end
end
