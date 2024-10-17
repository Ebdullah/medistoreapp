class Refund < ApplicationRecord
  belongs_to :record
  belongs_to :customer, class_name: 'User', foreign_key: 'customer_id'


  enum status: { pending: 0, refunded: 1, rejected: 2 }
  validates :amount, presence: true, numericality: { greater_than: 0 }

end
