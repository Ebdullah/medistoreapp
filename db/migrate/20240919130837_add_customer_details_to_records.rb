class AddCustomerDetailsToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :customer_name, :string
    add_column :records, :customer_phone, :string
  end
end
