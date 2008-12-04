require 'activesupport' unless defined? ActiveSupport
require 'activerecord' unless defined? ActiveRecord

require 'mailchimp_fu/base'

ActiveRecord::Base.send(:include, BigBentoBox::MailchimpFu)