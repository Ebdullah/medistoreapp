class CreateRefunds < ActiveRecord::Migration[7.1]
  def change
    create_table :refunds do |t|
      t.references :record, null: false, foreign_key: true
      t.integer :status, default: 0
      t.float :amount

      t.timestamps
    end
  end
end
