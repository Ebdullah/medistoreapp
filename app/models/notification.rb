class Notification < ApplicationRecord
  belongs_to :customer, class_name: 'User'
  belongs_to :branch, class_name: 'Branch', optional: true

end
