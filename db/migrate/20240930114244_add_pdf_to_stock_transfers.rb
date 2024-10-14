class AddPdfToStockTransfers < ActiveRecord::Migration[7.1]
  def change
    add_column :stock_transfers, :pdf, :string
  end
end
