class RemoveExpiredFromMedicines < ActiveRecord::Migration[7.1]
  def change
    remove_column :medicines, :expired, :boolean
  end
end
