class AuditLog < ApplicationRecord
  belongs_to :cashier, class_name: 'User'
  belongs_to :record
  belongs_to :medicine

  before_save :set_audited_to

  private

  def set_audited_to
    self.audited_to = audited_from + 90.days
  end
  
end
