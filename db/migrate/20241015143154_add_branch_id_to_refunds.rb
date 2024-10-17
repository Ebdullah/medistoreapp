class AddBranchIdToRefunds < ActiveRecord::Migration[7.1]
  def change
    add_column :refunds, :branch_id, :integer
  end
end
