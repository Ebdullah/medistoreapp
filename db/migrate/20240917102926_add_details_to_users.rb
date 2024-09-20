class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :phone, :string
    add_reference :users, :branch, null: false, foreign_key: true
    add_column :users, :role, :integer, null: false
  end
end
