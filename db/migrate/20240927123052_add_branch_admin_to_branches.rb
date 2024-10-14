class AddBranchAdminToBranches < ActiveRecord::Migration[7.1]
  def change
    add_column :branches, :branch_admin_id, :integer
  end
end
