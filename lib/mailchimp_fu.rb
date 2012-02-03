require 'rubygems'
require 'active_support'
require 'active_record'
require 'mailchimp_fu/base'

ActiveRecord::Base.send(:include, DonaldPiret::MailchimpFu)