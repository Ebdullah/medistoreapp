class Branch < ApplicationRecord
    has_many :users, dependent: :destroy
    has_many :medicines, dependent: :destroy
    has_many :records, dependent: :destroy

    has_many :stock_transfers_as_requesting, class_name: 'StockTransfer', foreign_key: 'requesting_branch_id', dependent: :destroy
    has_many :stock_transfers_as_receiving, class_name: 'StockTransfer', foreign_key: 'requesting_branch_id', dependent: :destroy

    validates :name, :location, presence: true
end
