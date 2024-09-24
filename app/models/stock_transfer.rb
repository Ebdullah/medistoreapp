class StockTransfer < ApplicationRecord
  belongs_to :requesting_branch, class_name: 'Branch', foreign_key: 'requesting_branch_id'
  belongs_to :receiving_branch, class_name: 'Branch', foreign_key: 'receiving_branch_id'

  enum status: [:pending, :approved, :denied]
  validates :medicines, presence: true
end
