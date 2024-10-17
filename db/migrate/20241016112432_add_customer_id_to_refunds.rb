class AddCustomerIdToRefunds < ActiveRecord::Migration[7.1]
  def change
    add_column :refunds, :customer_id, :integer
  end
end
