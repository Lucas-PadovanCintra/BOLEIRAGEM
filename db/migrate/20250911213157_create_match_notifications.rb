class CreateMatchNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :match_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :match, null: false, foreign_key: true
      t.boolean :viewed, default: false, null: false
      t.text :message

      t.timestamps
    end

    add_index :match_notifications, [:user_id, :viewed]
  end
end
