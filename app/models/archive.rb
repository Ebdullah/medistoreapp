class Archive < ApplicationRecord
    belongs_to :branch
    belongs_to :user
    belongs_to :record 

    validates :record_id, presence: true
 
  end
  