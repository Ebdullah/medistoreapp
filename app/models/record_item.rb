class RecordItem < ApplicationRecord
  belongs_to :record
  belongs_to :medicine

  validates :medicine, presence: true

  validate :quantity_cannot_exceed_stock

  def quantity_cannot_exceed_stock
    if quantity.present? && quantity > medicine.stock_quantity
      errors.add(:quantity, "cannot be greater than available stock (#{medicine.stock_quantity})")
    end
  end
end
