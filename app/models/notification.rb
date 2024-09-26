class Notification < ApplicationRecord
  belongs_to :customer, class_name: 'User'
  belongs_to :branch_admin, class_name: 'User'
end
