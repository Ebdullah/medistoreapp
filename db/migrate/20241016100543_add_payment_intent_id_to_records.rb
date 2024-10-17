class AddPaymentIntentIdToRecords < ActiveRecord::Migration[7.1]
  def change
    add_column :records, :payment_intent_id, :string
  end
end
