class CreateArchives < ActiveRecord::Migration[7.1]
  def change
    create_table :archives do |t|
      t.references :branch, foreign_key: true, null: false       
      t.references :user, foreign_key: true, null: false         
      t.references :record, foreign_key: { to_table: :records }, null: false 
      t.jsonb :record_data
      t.datetime :deleted_at, null: false 

      t.timestamps
    end
  end
end
