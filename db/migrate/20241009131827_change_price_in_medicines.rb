class ChangePriceInMedicines < ActiveRecord::Migration[7.1]
  def change
    change_column :medicines, :price, :float
  end
end
