require 'rubygems'
gem 'rspec'
require 'spec'

$KCODE='u'
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'mailchimp_fu'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :users do |t|
      t.string :username, :email, :first_name, :last_name, :city
      t.integer :age
      t.boolean :male
    end
  end
end

setup_db

def cleanup_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.execute("DELETE FROM #{table}")
  end
end

class User < ActiveRecord::Base
  acts_as_mailchimp_subscriber :sample
end