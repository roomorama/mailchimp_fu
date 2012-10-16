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