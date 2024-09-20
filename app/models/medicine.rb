class Medicine < ApplicationRecord
  belongs_to :branch
  has_many :record_items
  has_many :audit_logs

  validates :name, :price, :stock_quantity, :expiry_date, presence: true
end
