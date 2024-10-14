class Record < ApplicationRecord
  belongs_to :customer, class_name: 'User'
  belongs_to :cashier, class_name: 'User'
  belongs_to :branch
  has_many :record_items, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :archives
  enum payment_method: [ :cash, :card]

  scope :active, -> {where(deleted_at: nil)}

  validates :total_amount, :payment_method, presence: true

  accepts_nested_attributes_for :record_items, allow_destroy: true
  after_create :deduct_medicine_quantities

  def soft_delete
    update(deleted_at: Time.current)
  end

  def restore
    update(deleted_at: nil)
  end

  def archive_record(current_user)
    Archive.create!(
      branch: branch,
      user: current_user,
      record: self,
      record_data: attributes,
      deleted_at: Time.current
    )
  end

  protected

  def deduct_medicine_quantities
    record_items.each do |item|
      medicine = Medicine.find(item.medicine_id)
      medicine.update(stock_quantity: medicine.stock_quantity - item.quantity)
    end
  end

end
