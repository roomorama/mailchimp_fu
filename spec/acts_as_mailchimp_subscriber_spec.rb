require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe DonaldPiret::MailchimpFu::MailchimpSubscriber do
  
  describe :initialize do
    use_vcr_cassette :mailchimp_lists
    
    it "should correctly fetch the mailchimp list id" do
      User.mailchimp_list_name.should_not be_blank
      User.mailchimp_list_id.should_not be_blank
    end
  end
  
  describe :create do
    
    before(:each) do

    end
  
    it "should call the after_mailchimp_subscriber_create method on an object that has mailchimp_subscriber mixed in" do
      @user = User.new
      @user.should_receive(:after_mailchimp_subscriber_create)
      @user.save
    end
  
    it "should call MailChimp.list_subscribe with 'sample' as list name and the user's email on user creation if the user's wants email is tue" do
      @user = User.new(:email => 'test@test.com', :wants_email => true)
      Gibbon.any_instance.should_receive(:list_subscribe).with({:id=>"xxxxxxxx", :email_address=>"test@test.com", :merge_vars=>{}}).and_return(true)
      @user.save
    end
  
    it "should correctly set the mailchimp_vars" do
      @user = UserWithMergeVars.new(:email => 'donald@donaldpiret.com', :first_name => 'Donald', :last_name => 'Piret', :username => 'donaldpiret', :city => 'waterloo', :age => 24, :male => true)
      Gibbon.any_instance.should_receive(:list_subscribe).with({:id => 'xxxxxxxx', :email_address => 'donald@donaldpiret.com', :merge_vars => {:FIRST_NAME => 'Donald', :LAST_NAME => 'Piret', :USERNAME => 'donaldpiret', :MY_CITY => 'WATERLOO', :AGE => 24, :MALE => true, :STATIC => 'Static'}}).and_return(true)
      @user.save
    end
  
  end
  
  describe :update do
    it "should call the after_mailchimp_subscriber_update method on an object that has the mailchimp subscriber mixed in" do
      @user = User.create(:email => 'donald@donaldpiret.com', :first_name => 'donald', :wants_email => true)
      @user.should_receive(:around_mailchimp_subscriber_update)
      @user.update_attribute(:first_name, 'piret')
    end
    
    it "should call MailChimp.list_update_member with the old email address if the email address was changed" do
      @user = User.create(:email => 'donald@donaldpiret.com', :first_name => 'donald', :wants_email => true)
      Gibbon.any_instance.should_receive(:list_update_member).with({:id => 'xxxxxxxx', :email_address => 'donald@donaldpiret.com', :merge_vars => {:EMAIL => 'test@test.com'}})
      @user.update_attribute(:email, 'test@test.com')
    end
    
    it "should correctly set the mailchimp_vars" do
      Gibbon.any_instance.should_receive(:list_subscribe).with({:id => 'sample', :email_address => 'donald@donaldpiret.com', :merge_vars => {:FIRST_NAME => 'Donald', :LAST_NAME => 'Piret', :USERNAME => 'donaldpiret', :MY_CITY => 'WATERLOO', :AGE => 24, :MALE => true, :STATIC => 'Static'}}).and_return(true)
      @user = UserWithMergeVars.create(:email => 'donald@donaldpiret.com', :first_name => 'Donald', :last_name => 'Piret', :username => 'donaldpiret', :city => 'waterloo', :age => 24, :male => true)
      Gibbon.any_instance.should_receive(:list_update_member).with({:id => 'xxxxxxxx', :email_address => 'donald@donaldpiret.com', :merge_vars => {:EMAIL => 'test@test.com', :FIRST_NAME => 'Daniel', :LAST_NAME => 'Piret', :USERNAME => 'donaldpiret', :MY_CITY => 'WATERLOO', :AGE => 24, :MALE => true, :STATIC => 'Static'}})
      @user.update_attributes!({:email => 'test@test.com', :first_name => 'Daniel'})
    end
    
    it "should call the MailChimp.list_subscribe method if the enabled method was changed from false to true" do
      @user = User.create(:email => 'donald@donaldpiret.com', :first_name => 'donald', :wants_email => false)
      @user.wants_email.should eql(false)
      Gibbon.any_instance.should_receive(:list_subscribe).with({:id => 'xxxxxxxx', :email_address => 'donald@donaldpiret.com', :merge_vars => {}})
      @user.update_attribute(:wants_email, true)
    end
    
    it "should call the MailChimp.list_unsubscribe method if the enabled method was changed from true to false" do
      @user = User.create(:email => 'donald@donaldpiret.com', :first_name => 'donald', :wants_email => true)
      @user.wants_email.should eql(true)
      Gibbon.any_instance.should_receive(:list_unsubscribe).with({:id => 'xxxxxxxx', :email_address => 'donald@donaldpiret.com'})
      @user.update_attribute(:wants_email, false)
    end
    
  end
  
  describe :destroy do
    
    before(:each) do
      @user = User.create(:email => 'donald@donaldpiret.com', :first_name => 'donald')
    end
    
    it "should call the after_mailchimp_subscriber_destroy method on an object that has the mailchimp subscriber mixed in" do
      @user.should_receive(:after_mailchimp_subscriber_destroy)
      @user.destroy
    end
    
    it "should call MailChimp.list_unsubscribe with the user's email" do
      Gibbon.any_instance.should_receive(:list_unsubscribe).with({:id => 'xxxxxxxx', :email_address => 'donald@donaldpiret.com'})
      @user.destroy
    end
    
  end
  
end