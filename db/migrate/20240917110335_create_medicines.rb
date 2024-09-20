class CreateMedicines < ActiveRecord::Migration[7.1]
  def change
    create_table :medicines do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.integer :stock_quantity
      t.date :expiry_date
      t.references :branch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
