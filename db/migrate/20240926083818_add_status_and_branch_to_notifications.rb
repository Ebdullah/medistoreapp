class AddStatusAndBranchToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :status, :string
    add_reference :notifications, :branch, null: true, foreign_key: true
  end
end
