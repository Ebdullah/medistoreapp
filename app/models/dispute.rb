class Dispute < ApplicationRecord
  belongs_to :branch
  belongs_to :record

  has_one_attached :pdf

  validates :reason, presence: true
  enum status: { pending: 0, failed: 1, won: 2 }
end
