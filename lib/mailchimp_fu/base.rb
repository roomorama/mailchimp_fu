#require 'xmlrpc/client'
require 'mailchimp_fu/merge_vars'
require 'mailchimp_fu/acts/mailchimp_subscriber'

module DonaldPiret
  module MailchimpFu
    
    def self.included(base)
      base.send(:extend, ClassMethods)
    end
    
    module ClassMethods
      
      def acts_as_mailchimp_subscriber(list, opts = {}, &block)
        class_attribute :mailchimp_list_name
        class_attribute :mailchimp_list_id
        class_attribute :mailchimp_email_column
        class_attribute :mailchimp_enabled_column
        class_attribute :mailchimp_merge_vars
        
        self.mailchimp_list_name = list.to_s
        self.mailchimp_email_column = opts[:email] || 'email'
        self.mailchimp_enabled_column = opts[:enabled]
        self.mailchimp_merge_vars = MergeVars.new(&block)
        
        self.send(:include, MailchimpSubscriber)
      end
    end
  end
end