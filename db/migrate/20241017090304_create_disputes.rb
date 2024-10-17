class CreateDisputes < ActiveRecord::Migration[7.1]
  def change
    create_table :disputes do |t|
      t.references :branch, null: false, foreign_key: true
      t.references :record, null: false, foreign_key: true
      t.string :reason, null: false
      t.string :status, default: 'pending'
      t.string :pdf

      t.timestamps
    end
  end
end
