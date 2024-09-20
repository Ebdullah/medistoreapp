class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.references :customer, null: false, foreign_key: {to_table: :users}
      t.text :message

      t.timestamps
    end
  end
end
