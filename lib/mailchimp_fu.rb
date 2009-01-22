require 'rubygems'
require 'activesupport'
require 'activerecord'
require 'mailchimp_fu/base'

ActiveRecord::Base.send(:include, BigBentoBox::MailchimpFu)