class AddBranchIdToAuditLogs < ActiveRecord::Migration[7.1]
  def change
    add_column :audit_logs, :branch_id, :integer
    add_index :audit_logs, :branch_id
    add_foreign_key :audit_logs, :branches
  end
end
