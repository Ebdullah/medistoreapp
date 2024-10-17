class AddSkuToMedicines < ActiveRecord::Migration[7.1]
  def change
    add_column :medicines, :sku, :string
  end
end
