class ChangeTotalAmountToFloatInRecords < ActiveRecord::Migration[7.1]
  def change
    change_column :records, :total_amount, :float
  end
end
