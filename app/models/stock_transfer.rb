class StockTransfer < ApplicationRecord
  belongs_to :requesting_branch, class_name: 'Branch'
  belongs_to :receiving_branch, class_name: 'Branch'

  enum status: [:pending, :approved, :denied]

  # serialize :medicines, JSON

  validates :medicines, presence: true
end
