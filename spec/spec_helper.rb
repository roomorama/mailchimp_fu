begin
  #require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
  ENV["RAILS_ENV"] = "test"
  require 'rubygems'
  require 'active_record'
  require 'spec'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

ENV["RAILS_ROOT"] = File.dirname(__FILE__) + '/../../../..'
RAILS_ROOT = File.dirname(__FILE__) + '/../../../..'

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'mailchimp_fu'
 
plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")
 

databases = YAML::load(IO.read(plugin_spec_dir + "/db/database.yml"))
ActiveRecord::Base.establish_connection(databases[ENV["DB"] || "sqlite3"])
load(File.join(plugin_spec_dir, "db", "schema.rb"))