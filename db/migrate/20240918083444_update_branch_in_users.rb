class UpdateBranchInUsers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :users, :branch, foreign_key: true

    add_reference :users, :branch, null: true
  end
end
