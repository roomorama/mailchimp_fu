require 'xmlrpc/client'
require 'mailchimp_fu/acts/mailchimp_subscriber'
require 'mailchimp_fu/mail_chimp'

module BigBentoBox
  module MailchimpFu
    
    def self.included(base)
      base.send(:extend, ClassMethods)
    end
    
    module ClassMethods
      
      def acts_as_mailchimp_subscriber(:list, &block)
        #self.send(:include, MailchimpSubscriber)
      end
        
    end
  end
end