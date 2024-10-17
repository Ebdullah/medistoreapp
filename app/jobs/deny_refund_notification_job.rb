class DenyRefundNotificationJob < ApplicationJob
  queue_as :default

  def perform(refund)
    customer = refund.customer
    return unless customer # Ensure customer exists

    message = "Your refund against order# #{refund.record_id} of amount #{refund.amount} has been denied."
    Notification.create!(customer_id: customer.id, message: message, branch_id: refund.record.branch_id, status: 'unread')
  end
end
