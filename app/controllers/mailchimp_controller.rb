class MailchimpController < ActionController::Base
  
  def callback
    logger.info "Called callback with: #{params.inspect}. Request: #{request.inspect}"
    requesttype = params[:type]
    data = params[:data]
    case requesttype
      when "subscribe"
        logger.info "Calling Subscribe from web callback for #{data[:email]}"
        subscribe(data)
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

  def subscribe(data)
    user = User.where({User.mailchimp_email_column.to_sym => data[:email]}).first
    if user
      user.update_attribute(User.mailchimp_enabled_column.to_sym, true) unless user.send(User.mailchimp_enabled_column.to_sym) == true
      user.send(:mailchimp_after_subscribe) if user.respond_to?(:mailchimp_after_subscribe)
    end
  end

  def unsubscribe(data)
    user = User.where({User.mailchimp_email_column.to_sym => data[:email]}).first
    raise ActiveRecord::RecordNotFound if user.nil?
    user.update_attribute(User.mailchimp_enabled_column.to_sym, false)
    user.send(:mailchimp_after_unsubscribe) if user.respond_to?(:mailchimp_after_unsubscribe)
    logger.info "Mailchimp Webhook Unsubscribe: Unsubscribed user with email #{data[:email]}"
  rescue ActiveRecord::RecordNotFound
    logger.error "Mailchimp Webhook Unsubscribe: Could not find user with email #{data[:email]}"
  end
  
  def clean(data)
    user = User.where({User.mailchimp_email_column.to_sym => data[:email]}).first
    raise ActiveRecord::RecordNotFound if user.nil?
    user.update_attribute(User.mailchimp_enabled_column.to_sym, false)
    user.send(:mailchimp_after_clean) if user.respond_to?(:mailchimp_after_clean)
    logger.info "Mailchimp Webhook Clean: Unsubscribed user with email #{data[:email]}"
  rescue ActiveRecord::RecordNotFound
    logger.error "Mailchimp Webhook Clean: Could not find user with email #{data[:email]}"
  end
  
end