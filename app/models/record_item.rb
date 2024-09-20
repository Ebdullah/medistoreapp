class RecordItem < ApplicationRecord
  belongs_to :record
  belongs_to :medicine

  validates :medicine, presence: true
end
