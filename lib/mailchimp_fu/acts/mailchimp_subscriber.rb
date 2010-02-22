require 'xmlrpc/client'
require 'mail_chimp'

module DonaldPiret
  module MailchimpFu
    
    # This module is mixed into the mailchimp list subscriber classes
    #
    # ==== Callbacks
    # *
    module MailchimpSubscriber
      
      begin
        Object.send(:include, Delayed::MessageSending)   
        Module.send(:include, Delayed::MessageSending::ClassMethods)
      rescue Exception
        puts "Could not load delayed job"
      end
      
      def self.included(base)
        base.extend ClassMethods
        mattr_reader :mailchimp_config
        mattr_reader :mailchimp_apikey
        begin
          @@mailchimp_config = YAML.load(File.open("#{RAILS_ROOT}/config/mailchimp_fu.yml"))[Rails.env.to_s].symbolize_keys rescue nil
          @@mailchimp_apikey = MailChimp.login(@@mailchimp_config[:username], @@mailchimp_config[:password])
        rescue
        end
        base.instance_eval do
          after_create :after_mailchimp_subscriber_create
          before_update :before_mailchimp_subscriber_update
          after_destroy :after_mailchimp_subscriber_destroy
        end
      end
      
      # Merge vars method
      def mailchimp_merge_var(key)
        value = self.mailchimp_merge_vars[key]
        if value.is_a? Symbol
          self.send(value)
        else
          return value
        end
      end
      
      # After subscriber created callback
      # Do initial list registration
      def after_mailchimp_subscriber_create
        email_address = self.send(self.mailchimp_email_column.to_sym)
        merge_vars = {}
        self.mailchimp_merge_vars.each { |mv|
          merge_vars[mv.to_sym] = mailchimp_merge_var(mv) unless mailchimp_merge_var(mv).nil?
        }
        wants_email = self.send(self.mailchimp_enabled_column.to_sym)
        if wants_email
          logger.info "Calling MailchimpWorker Async Subscribe after create"
          MailChimp.list_subscribe(self.mailchimp_list_name, email_address, merge_vars)
        end
      rescue => e
        if e.message =~ /is already subscribed to list/
          # User is already subscribed to list, so update instead
          MailChimp.list_update_member(self.mailchimp_list_name, email_address, merge_vars)
        else
          raise e  
        end
      end
      handle_asynchronously :after_mailchimp_subscriber_create if defined?(Delayed::MessageSending) && !Rails.env.test?
      
      
      # before subscriber update callback
      # Do list update
      def before_mailchimp_subscriber_update
        if self.send("#{self.mailchimp_email_column}_changed?") 
          email_address = self.send("#{self.mailchimp_email_column}_was") || self.send("#{self.mailchimp_email_column}")
          merge_vars = {:email => self.send(self.mailchimp_email_column.to_sym)}
        else
          email_address = self.send(self.mailchimp_email_column.to_sym)
          merge_vars = {}
        end
        self.mailchimp_merge_vars.each { |mv|
          merge_vars[mv.to_sym] = mailchimp_merge_var(mv) unless mailchimp_merge_var(mv).nil?
        }
        # Subscribe or unsubscribe the user if the enabled field has changed
        wants_email = self.send(self.mailchimp_enabled_column.to_sym)
        wants_email_changed = self.send((self.mailchimp_enabled_column.to_s + "_changed?").to_sym)
        options = {:list_name => self.mailchimp_list_name, :email_address => email_address, :merge_vars => merge_vars}
        if wants_email_changed
          if wants_email
            logger.info "Calling MailchimpWorker Async Subscribe With Update after update"
            MailChimp.list_subscribe(self.mailchimp_list_name, email_address, merge_vars)
          else
            logger.info "Calling MailchimpWorker Async Unsubscribe after update"
            MailChimp.list_unsubscribe(self.mailchimp_list_name, email_address)
          end
        elsif wants_email
          logger.info "Calling MailchimpWorker Async Update after update"
          MailChimp.list_update_member(self.mailchimp_list_name, email_address, merge_vars)
        end
      rescue => e
        if e.message =~ /is already subscribed to list/
          # User is already subscribed to list, so update instead
          MailChimp.list_update_member(self.mailchimp_list_name, email_address, merge_vars)
        elsif e.message.strip =~ /^There is no record of "(.+)" in the database$/
          MailChimp.list_subscribe(self.mailchimp_list_name, email_address, merge_vars)
        elsif e.message.strip =~ /^The email address "(.+)" does not belong to this list$/
          self.update_attribute(self.mailchimp_enabled_column.to_sym, false)
        else
          raise e  
        end
      end
      handle_asynchronously :before_mailchimp_subscriber_update if defined?(Delayed::MessageSending) && !Rails.env.test?
      
      # After subscriber destroy callback
      # Remove from list
      def after_mailchimp_subscriber_destroy
        email_address = self.send(self.mailchimp_email_column.to_sym)
        logger.info "Calling MailchimpWorker Async Unsusbscribe after destroy"
        MailChimp.list_unsubscribe(self.mailchimp_list_name, email_address)
      rescue => e
        if e.message.strip =~ /^There is no record of "(.+)" in the database$/
          # Do nothing
        else
          raise e
        end
      end
      handle_asynchronously :after_mailchimp_subscriber_destroy if defined?(Delayed::MessageSending) && !Rails.env.test?
      
      module ClassMethods
        
      end
    end
  end
end