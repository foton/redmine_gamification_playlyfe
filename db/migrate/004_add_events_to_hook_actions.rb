class AddEventsToHookActions < ActiveRecord::Migration
  def change
    add_column :hooks_to_actions, :event_source, :string
    add_column :hooks_to_actions, :event_name, :string
    change_column :hooks_to_actions, :hook_id, :string, null: true
    
    add_index :hook_to_actions, :event_source
    add_index :hook_to_actions, :event_name
  end
end
