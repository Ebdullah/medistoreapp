class AddDefaultStatusToDisputes < ActiveRecord::Migration[7.1]
  def up
    change_column :disputes, :status, :integer, default: 0, using: "CASE status
      WHEN 'pending' THEN 0
      WHEN 'failed' THEN 1
      WHEN 'won' THEN 2
      ELSE 0
    END"
  end

  def down
    change_column :disputes, :status, :string
  end
end
