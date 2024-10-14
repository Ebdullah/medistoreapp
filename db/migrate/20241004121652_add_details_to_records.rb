class AddDetailsToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :house_no, :string
    add_column :records, :postal_code, :string
    add_column :records, :address, :string
  end
end
