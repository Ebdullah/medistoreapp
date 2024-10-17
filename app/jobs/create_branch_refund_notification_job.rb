class CreateBranchRefundNotificationJob < ApplicationJob
  queue_as :default

  def perform(branch, refund)
    customer = refund.customer
    return unless customer

    branch_admin = User.where(branch_id: branch.id, role: :branch_admin).first
    return unless branch_admin

    puts "#{branch_admin.name}"
    message = "Refund has been created by #{refund.customer.name} against order# #{refund.record_id} of amount $#{refund.amount}."
    Notification.create!(customer_id: branch_admin.id, message: message, branch_id: refund.record.branch_id, status: 'unread')
  end
end
