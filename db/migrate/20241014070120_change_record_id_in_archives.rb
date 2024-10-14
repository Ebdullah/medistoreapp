class ChangeRecordIdInArchives < ActiveRecord::Migration[7.1]
  def change
    change_column_null :archives, :record_id, true
  end
end
