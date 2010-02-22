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
          @@mailchimp_config = YAML.load(File.open("#{ENV['RAILS_ROOT']}/config/mailchimp_fu.yml"))[ENV["RAILS_ENV"]].symbolize_keys
          @@mailchimp_apikey = MailChimp.login(@@mailchimp_config[:username], @@mailchimp_config[:password]) unless ENV["RAILS_ENV"] == 'test'
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
          merge_vars[mv.to_sym] = mailchimp_merge_var(mv)
        }
        MailChimp.list_subscribe(self.mailchimp_list_name, email_address, merge_vars)
      end
      handle_asynchronously :after_mailchimp_subscriber_create if defined?(Delayed::MessageSending) && !Rails.env.test?
      
      
      # before subscriber update callback
      # Do list update
      def after_mailchimp_subscriber_update
        if self.send("#{self.mailchimp_email_column}_changed?") 
          email_address = self.send("#{self.mailchimp_email_column}_was")
          merge_vars = {:EMAIL => self.send(self.mailchimp_email_column.to_sym)}
        else
          email_address = self.send(self.mailchimp_email_column.to_sym)
          merge_vars = {}
        end
        self.mailchimp_merge_vars.each { |mv|
          merge_vars[mv.to_sym] = mailchimp_merge_var(mv)
        }
        # Subscribe or unsubscribe the user if the enabled field has changed
        if self.mailchimp_enabled_column && self.send("#{self.mailchimp_enabled_column}_changed?")
          self.send(self.mailchimp_enabled_column.to_sym) ? MailChimp.list_subscribe(self.mailchimp_list_name, email_address) : MailChimp.list_unsubscribe(self.mailchimp_list_name, email_address)
        end
        # Then update the member
        MailChimp.list_update_member(self.mailchimp_list_name, email_address, merge_vars)
      end
      handle_asynchronously :before_mailchimp_subscriber_update if defined?(Delayed::MessageSending) && !Rails.env.test?
      
      # After subscriber destroy callback
      # Remove from list
      def after_mailchimp_subscriber_destroy
        email_address = self.send(self.mailchimp_email_column.to_sym)
        MailChimp.list_unsubscribe(self.mailchimp_list_name, email_address)
      end
      handle_asynchronously :after_mailchimp_subscriber_destroy if defined?(Delayed::MessageSending) && !Rails.env.test?
      
      module ClassMethods
        
      end
    end
  end
end
