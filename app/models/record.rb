class Record < ApplicationRecord
  belongs_to :customer, class_name: 'User'
  belongs_to :cashier, class_name: 'User'
  belongs_to :branch
  has_many :record_items, dependent: :destroy

  enum payment_method: [ :cash, :card ]

  validates :total_amount, :payment_method, presence: true

  accepts_nested_attributes_for :record_items, allow_destroy: true
  after_create :deduct_medicine_quantities

  private
  def deduct_medicine_quantities
    record_items.each do |item|
      medicine = Medicine.find(item.medicine_id)
      medicine.update(stock_quantity: medicine.stock_quantity - item.quantity)
    end
  end
end
