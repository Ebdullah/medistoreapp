class StockTransfer < ApplicationRecord
  has_one_attached :pdf
  belongs_to :requesting_branch, class_name: 'Branch', foreign_key: 'requesting_branch_id'
  belongs_to :receiving_branch, class_name: 'Branch', foreign_key: 'receiving_branch_id'

  enum status: [:pending, :approved, :denied]
  validates :medicines, presence: true
  validate :pdf_content_type

  private

  def pdf_content_type
    if pdf.attached? && !pdf.content_type.in?(%('application/pdf'))
      errors.add(:pdf, 'must be a PDF file')
    end
  end
end
