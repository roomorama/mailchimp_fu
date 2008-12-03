require 'xmlrpc/client'
module BigBentoBox
  module Acts
    module MailchimpSubscriber
      
      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end