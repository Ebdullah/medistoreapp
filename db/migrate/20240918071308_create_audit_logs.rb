class CreateAuditLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :audit_logs do |t|
      t.references :cashier, null: false, foreign_key: {to_table: :users}
      t.references :record, null: false, foreign_key: true
      t.references :medicine, null: false, foreign_key: true
      t.integer :quantity_sold
      t.decimal :total_amount
      t.datetime :audited_from
      t.datetime :audited_to

      t.timestamps
    end
  end
end
