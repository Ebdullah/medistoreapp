class AddDeletedAtToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :deleted_at, :datetime
  end
end
