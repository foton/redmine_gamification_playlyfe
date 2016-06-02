class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :user_id, null: false
      t.string :player_id, null: false
    end

    add_index :players, :user_id, unique: true
    add_index :players, :player_id
    add_foreign_key :players, :users, column: :user_id

  end
end
