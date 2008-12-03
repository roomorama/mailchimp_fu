require 'acts_as_mailchimp_subscriber'
ActiveRecord::Base.send(:include, BigBentoBox::Acts::MailchimpSubscriber)