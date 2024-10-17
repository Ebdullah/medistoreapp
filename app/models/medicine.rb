class Medicine < ApplicationRecord
  belongs_to :branch
  has_many :record_items
  has_many :audit_logs

  validates :sku, presence: true, uniqueness: true
  validates :name, :price, :stock_quantity, :expiry_date, presence: true
  validates :name, uniqueness: { 
    scope: :branch_id, 
    message: "Medicine already exists in this branch", if: :new_record?
  }  
  validates :price, numericality: { greater_than: 0 }
  validates :stock_quantity, numericality: { only_integer: true, greater_than: 0, message: "must be a positive number greater than zero" } 



  validate :expiry_date_cannot_be_in_the_past

  scope :active, -> { where(expired: false) }
 
  def self.check_expiry
    Medicine.where('expiry_date < ?', Date.today).update_all(expired: true)
  end
  private

  def expiry_date_cannot_be_in_the_past
    if expiry_date.present? && expiry_date < Date.today
      errors.add(:expiry_date, "cannot be in the past")
    end
  end
end
