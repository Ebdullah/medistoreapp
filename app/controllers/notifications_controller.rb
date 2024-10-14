class NotificationsController < ApplicationController
    before_action :set_branch
    before_action :set_notifications, only: [:show, :destroy]
    before_action :authorize_notifications
  
    def index
        @notifications = policy_scope(Notification).order(created_at: :desc)
    end

    def show
        authorize @notification
        if @notification.status == 'unread'
            @notification.update(status: 'read')
        end
        @notification
    end

    def destroy
        @notification.destroy
        redirect_to notifications_path, notice: 'Notification was successfully deleted.'
    end
  
    private
  
    def set_branch
        @branch = current_user.branch
    end

    def set_notifications
        @notification = Notification.find(params[:id])
    end

    def authorize_notifications
        authorize Notification
    end
  end
  