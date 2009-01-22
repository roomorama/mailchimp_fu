require File.dirname(__FILE__) + '/spec_helper.rb'

class User < ActiveRecord::Base
  acts_as_mailchimp_subscriber :sample, :email
  
  def email
    "test@test.com"
  end
end


describe BigBentoBox::MailchimpFu::MailchimpSubscriber do
  
  it "should call the after_mailchimp_subscriber_create method on an object that has mailchimp_subscriber mixed in" do
    @user = User.new
    @user.should_receive(:after_mailchimp_subscriber_create)
    @user.save
  end
  
end