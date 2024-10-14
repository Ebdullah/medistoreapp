class ChangeExpiredDefaultInMedicines < ActiveRecord::Migration[7.1]
  def change
    change_column_default :medicines, :expired, from: nil, to: false
  end
end
