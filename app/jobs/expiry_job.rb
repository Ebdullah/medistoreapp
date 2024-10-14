class ExpiryJob < ApplicationJob
  queue_as :default

  def perform
    Medicine.where('expiry_date < ?', Date.today).update_all(expired: true)
    # expired_medicines = Medicine.where('expiry_date < ?', Date.today)
    # expired_medicines.update_all(expired: true) unless expired_medicines.empty?
    # Medicine.where('expiry_date < ?', Date.today).find_each do |medicine|
    #   if medicine.expiry_date < Date.today
    #     medicine.update(expired: true)
    #   end
    # end
  end
end
