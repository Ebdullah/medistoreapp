class Branch < ApplicationRecord
    belongs_to :branch_admin, class_name: 'User', foreign_key: 'branch_admin_id'
    has_many :users, dependent: :destroy
    has_many :medicines, dependent: :destroy
    has_many :records, dependent: :destroy
    has_many :audit_logs, dependent: :destroy
    has_many :archives, dependent: :destroy
    has_many :disputes, dependent: :destroy

    has_many :notifications, dependent: :destroy

    has_many :stock_transfers, foreign_key: :requesting_branch_id
    has_many :stock_transfers_as_receiving, class_name: 'StockTransfer', foreign_key: 'requesting_branch_id'

    validates :name, :location, presence: true
end
