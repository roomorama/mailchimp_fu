require 'fileutils'
config_file = File.dirname(__FILE__) + '/../../../config/mailchimp_fu.yml'
FileUtils.cp File.dirname(__FILE__) + '/mailchimp_fu.yml.example', config_file unless File.exists?(config_file)
puts IO.read(File.join(File.dirname(__FILE__), 'README.textile'))