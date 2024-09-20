class ChangeBranchIdInUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_null :users, :branch_id, true
  end
end
