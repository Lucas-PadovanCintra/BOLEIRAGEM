class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      @unviewed_notifications = current_user.unviewed_notifications.includes(match: [:teams])
      Rails.logger.info "User #{current_user.email} has #{@unviewed_notifications.count} unviewed notifications"
    end
  end
  
  def mark_notifications_viewed
    if user_signed_in?
      current_user.match_notifications.where(id: params[:notification_ids]).update_all(viewed: true)
      head :ok
    else
      head :unauthorized
    end
  end
end
