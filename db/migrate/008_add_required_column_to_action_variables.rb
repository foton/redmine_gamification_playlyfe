class AddRequiredColumnToActionVariables < ActiveRecord::Migration
  def change
    add_column :gamification_action_variables, :required, :boolean, default: false
    add_index :gamification_action_variables, :variable
  end
end
