require 'fileutils'
config_file = File.dirname(__FILE__) + '/../../../config/mailchimp_fu.yml'
FileUtils.cp File.dirname(__FILE__) + '/mailchimp_fu.yml.example', config_file unless File.exists?(config_file)

workers_dir = File.dirname(__FILE__) + '/../../../workers'
worker_file = workers_dir + '/mailchimp_worker.rb'
File.mkdirs workers_dir unless File.exists?(workers_dir) 
FileUtils.cp File.dirname(__FILE__) + '/workers/mailchimp_worker.rb', worker_file unless File.exists?(worker_file)

puts IO.read(File.join(File.dirname(__FILE__), 'README.textile'))