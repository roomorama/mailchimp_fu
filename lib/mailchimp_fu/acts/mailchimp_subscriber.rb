require 'xmlrpc/client'
require 'mail_chimp'
module BigBentoBox
  module MailchimpFu
    
    # This module is mixed into the mailchimp list subscriber classes
    #
    # ==== Callbacks
    # *
    module MailchimpSubscriber
      def self.included(base)
        base.extend ClassMethods
        mattr_reader :mailchimp_config
        mattr_reader :mailchimp_apikey
        begin
          @@mailchimp_config = YAML.load(File.open("#{ENV['RAILS_ROOT']}/config/mailchimp_fu.yml"))[ENV["RAILS_ENV"]].symbolize_keys
          @@mailchimp_apikey = MailChimp.login(@@mailchimp_config[:username], @@mailchimp_config[:password])
        end
        
        base.instance_eval do
          after_create :after_mailchimp_subscriber_create
          after_update :after_mailchimp_subscriber_update
          after_destroy :after_mailchimp_subscriber_destroy
        end
      end
      
      # After subscriber created callback
      # Do initial list registration
      def after_mailchimp_subscriber_create
      end
      
      # After subscriber update callback
      # Do list update
      def after_mailchimp_subscriber_update
      end
      
      # After subscriber destroy callback
      # Remove from list
      def after_mailchimp_subscriber_destroy
      end
      
      module ClassMethods
        
      end
    end
  end
end