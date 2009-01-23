require File.dirname(__FILE__) + '/spec_helper.rb'

class User < ActiveRecord::Base
  acts_as_mailchimp_subscriber :sample, :email => :email, :enabled => :wants_email
  
end

class UserWithMergeVars < ActiveRecord::Base
  acts_as_mailchimp_subscriber :sample do
    first_name :first_name
    last_name :last_name
    username :username
    my_city :city
    age :age
    male :male?
    static 'Static'
  end
  
  def city
    self[:city].upcase
  end
end



describe DonaldPiret::MailchimpFu::MailchimpSubscriber do
  
  describe :create do
    
    before(:each) do
      MailChimp.stub!(:login).and_return(true)
      MailChimp.stub!(:api_key).and_return('TEST')
    end
  
    it "should call the after_mailchimp_subscriber_create method on an object that has mailchimp_subscriber mixed in" do
      @user = User.new
      @user.should_receive(:after_mailchimp_subscriber_create)
      @user.save
    end
  
    it "should call MailChimp.list_subscribe with 'sample' as list name and the user's email on user creation" do
      @user = User.new(:email => 'test@test.com')
      MailChimp.should_receive(:list_subscribe).with('sample','test@test.com', {}).and_return(true)
      @user.save
    end
  
    it "should correctly set the mailchimp_vars" do
      @user = UserWithMergeVars.new(:email => 'donald@donaldpiret.com', :first_name => 'Donald', :last_name => 'Piret', :username => 'donaldpiret', :city => 'waterloo', :age => 24, :male => true)
      MailChimp.should_receive(:list_subscribe).with('sample','donald@donaldpiret.com', :first_name => 'Donald', :last_name => 'Piret', :username => 'donaldpiret', :my_city => 'WATERLOO', :age => 24, :male => true, :static => 'Static').and_return(true)
      @user.save
    end
  
  end
  
  describe :update do
    
    before(:each) do
      MailChimp.stub!(:login).and_return(true)
      MailChimp.stub!(:api_key).and_return('TEST')
      MailChimp.should_receive(:list_subscribe).with('sample','donald@donaldpiret.com', {}).and_return(true)
      @user = User.create(:email => 'donald@donaldpiret.com', :first_name => 'donald', :wants_email => true)
    end
    
    it "should call the after_mailchimp_subscriber_update method on an object that has the mailchimp subscriber mixed in" do
      @user.should_receive(:after_mailchimp_subscriber_update)
      @user.update_attribute(:first_name, 'piret')
    end
    
    it "should call MailChimp.list_update_member with the old email address if the email address was changed" do
      MailChimp.should_receive(:list_update_member).with('sample','donald@donaldpiret.com', {:EMAIL => 'test@test.com'})
      @user.update_attribute(:email, 'test@test.com')
    end
    
    it "should correctly set the mailchimp_vars" do
      MailChimp.should_receive(:list_subscribe).with('sample','donald@donaldpiret.com', :first_name => 'Donald', :last_name => 'Piret', :username => 'donaldpiret', :my_city => 'WATERLOO', :age => 24, :male => true, :static => 'Static').and_return(true)
      @user = UserWithMergeVars.create(:email => 'donald@donaldpiret.com', :first_name => 'Donald', :last_name => 'Piret', :username => 'donaldpiret', :city => 'waterloo', :age => 24, :male => true)
      MailChimp.should_receive(:list_update_member).with('sample','donald@donaldpiret.com', {:EMAIL => 'test@test.com', :first_name => 'Daniel', :last_name => 'Piret', :username => 'donaldpiret', :my_city => 'WATERLOO', :age => 24, :male => true, :static => 'Static'})
      @user.update_attributes!({:email => 'test@test.com', :first_name => 'Daniel'})
    end
    
    it "should call the MailChimp.list_subscribe method if the enabled method was changed from false to true" do
      MailChimp.should_receive(:list_subscribe).with('sample','unsubbed@donaldpiret.com', {}).and_return(true)
      @user = User.create(:email => 'unsubbed@donaldpiret.com', :wants_email => false)
      @user.wants_email.should eql(false)
      MailChimp.should_receive(:list_subscribe).with('sample','unsubbed@donaldpiret.com')
      MailChimp.should_receive(:list_update_member).and_return(true)
      @user.update_attribute(:wants_email, true)
    end
    
    it "should call the MailChimp.list_unsubscribe method if the enabled method was changed from true to false" do
      @user.wants_email.should eql(true)
      MailChimp.should_receive(:list_unsubscribe).with('sample','donald@donaldpiret.com')
      MailChimp.should_receive(:list_update_member).and_return(true)
      @user.update_attribute(:wants_email, false)
    end
    
  end
  
  describe :destroy do
    
    before(:each) do
      MailChimp.stub!(:login).and_return(true)
      MailChimp.stub!(:api_key).and_return('TEST')
      MailChimp.should_receive(:list_subscribe).with('sample','donald@donaldpiret.com', {}).and_return(true)
      @user = User.create(:email => 'donald@donaldpiret.com', :first_name => 'donald')
    end
    
    it "should call the after_mailchimp_subscriber_destroy method on an object that has the mailchimp subscriber mixed in" do
      @user.should_receive(:after_mailchimp_subscriber_destroy)
      @user.destroy
    end
    
    it "should call MailChimp.list_unsubscribe with the user's email" do
      MailChimp.should_receive(:list_unsubscribe).with('sample', 'donald@donaldpiret.com')
      @user.destroy
    end
    
  end
  
end