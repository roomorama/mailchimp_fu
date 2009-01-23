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
        
        write_inheritable_attribute :mailchimp_list_name, list.to_s
        write_inheritable_attribute :mailchimp_email_column, opts[:email] || 'email'
        write_inheritable_attribute :mailchimp_enabled_column, opts[:enabled]
        write_inheritable_attribute :mailchimp_merge_vars, MergeVars.new(&block)
        
        class_inheritable_reader :mailchimp_list_name
        class_inheritable_reader :mailchimp_email_column
        class_inheritable_reader :mailchimp_enabled_column
        class_inheritable_reader :mailchimp_merge_vars
        
        self.send(:include, MailchimpSubscriber)
      end
    end
  end
end