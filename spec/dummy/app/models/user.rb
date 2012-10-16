class User < ActiveRecord::Base
  acts_as_mailchimp_subscriber :sample, :email => :email, :enabled => :wants_email
  
end