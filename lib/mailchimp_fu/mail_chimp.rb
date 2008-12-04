require 'xmlrpc/client'
module BigBentoBox
  module MailchimpFu
    class MailChimp
      class MailChimpLoginError < StandardError; end
      
      class << self
        
        def api_key
          @@api_key || raise(MailChimpLoginError.new, "You are not connected to the MailChimp API")
        end
        
        # Retrieve all of the lists defined for your user account
        def lists
          lists = xmlrpc_client.call("lists", api_key)
        end
        
        def list_subscribe(list_id, email, options*)
          
        end
        
        # Log into the MailChimp API and return an API key
        def login(username, password)
          @@api_key = xmlrpc_client.call("login", username, password)
        rescue
          logger.error("Could not login to the MailChimp API using username: #{username} and password: #{password}")
        end
        
        # Return an instance of the xml_rpc client for connecting to the mailchimp API
        def xmlrpc_client
          @@xmlrpc_client ||= XMLRPC::Client.new2("http://api.mailchimp.com/1.1/")
        end
        
      end
      
    end
  end
end