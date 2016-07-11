class CreateGamificationActionVariables < ActiveRecord::Migration
  def change
    create_table :gamification_action_variables do |t|
      t.string :action_id, null: false
      t.string :variable, null: false
      t.string :eval_string, null: false
    end

    add_index :gamification_action_variables, :action_id
  end
end
