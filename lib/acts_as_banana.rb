require 'xmlrpc/client'
module BigBentoBox
  module Acts
    module Banana
      
      def self.included(base)
        base.extend ClassMethods
      end
    end
  end
end