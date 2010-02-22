class MailchimpController < ActionController::Base
  
  def callback
    logger.info "Called callback with: #{params.inspect}. Request: #{request.inspect}"
    requesttype = params[:type]
    data = params[:data]
    case requesttype
      when "unsubscribe"
        logger.info "Calling Unsubscribe from web callback for #{data[:email]}"
        unsubscribe(data)
      when "cleaned"
        logger.info "Calling Cleaned from web callback for #{data[:email]}"
        clean(data)
      #when "profile"
      #  profilechange(data)
      #when "upemail"
      #  emailchange(data)
      #when "subscribe"
        #  subscribe(data)
    end
    render :nothing => true, :status => 200
  end
  
protected

  def unsubscribe(data)
    user = User.find(:first, :conditions => {user.mailchimp_email_column.to_sym => data[:email]}) || raise ActiveRecord::RecordNotFound
    user.update_attribute(user.mailchimp_enabled_column.to_sym, false)
    logger.info "Mailchimp Webhook Unsubscribe: Unsubscribed user with email #{data[:email]}"
  rescue ActiveRecord::RecordNotFound
    logger.error "Mailchimp Webhook Unsubscribe: Could not find user with email #{data[:email]}"
  end
  
  def clean(data)
    user = User.find(:first, :conditions => {user.mailchimp_email_column.to_sym => data[:email]}) || raise ActiveRecord::RecordNotFound
    user.update_attribute(user.mailchimp_enabled_column.to_sym, false)
    logger.info "Mailchimp Webhook Clean: Unsubscribed user with email #{data[:email]}"
  rescue ActiveRecord::RecordNotFound
    logger.error "Mailchimp Webhook Clean: Could not find user with email #{data[:email]}"
  end
  
end