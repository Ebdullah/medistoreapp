class CreateStockTransfers < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_transfers do |t|
      t.references :requesting_branch, null: false, foreign_key: {to_table: :branches}
      t.references :receiving_branch, null: false, foreign_key: {to_table: :branches}
      t.integer :status, default: 0

      t.jsonb :medicines
    end      
  end
end
