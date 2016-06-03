class CreateHookToActions < ActiveRecord::Migration
  def change
    create_table :hook_to_actions do |t|
      t.string :hook_id, null: false
      t.string :action_id, null: false
    end

    add_index :hook_to_actions, :action_id
    add_index :hook_to_actions, :hook_id
  end
end
