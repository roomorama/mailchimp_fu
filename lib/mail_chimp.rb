require 'xmlrpc/client'
class MailChimp
  class MailChimpLoginError < StandardError; end
  class MailChimpInterestGroupNotFoundError < StandardError; end
  class MailChimpListNotFoundError < StandardError; end
  @@api_key = nil
  @@cached_lists = nil
  
  class << self
    
    # Retrieve all of the lists defined for your user account
    def lists
      @@cached_lists = xmlrpc_client.call("lists", api_key)
    end
    
    #Subscribe a batch of email addresses to a list at once 
    # Batch is an array of either email addresses or hashes containing at least the :email field
    # This hash can contain other merge vars
    def list_batch_subscribe(name, user_hashes, double_optin = false, update_existing = true, replace_interests = true, default_type = 'html')
      batch_list = []
      user_hashes.each do |email|
        if email.is_a? String
          batch_list << {:EMAIL => email, :EMAIL_TYPE => default_type}
        elsif email.is_a? Hash
          email_address = email.delete(:email)
          email_type = email.delete(:email_type) || default_type
          merge_vars = {:EMAIL => email_address, :EMAIL_TYPE => email_type}
          email.each { |key, value|
            merge_vars[key.to_s.upcase] = value
          }
          batch_list << merge_vars
        end
      end
      xmlrpc_client.call("listBatchSubscribe", api_key, list_id(name), batch_list, double_optin, update_existing, replace_interests)
    end
    
    def list_batch_unsubscribe(name, emails, delete_member = false, send_goodbye = true, send_notify = false)
      xmlrpc_client.call("listBatchUnsubscribe", api_key, list_id(name), emails, delete_member, send_goodbye, send_notify)
    end
    
    # Add a single Interest Group
    def list_interest_group_add(name, group_name)
      name = list_name(name)
      xmlrpc_client.call("listInterestGroupAdd", api_key, list_id(name), group_name)
    end
    
    # Delete a single Interest Group
    def list_interest_group_del(name, group_name)
      name = list_name(name)
      begin
        xmlrpc_client.call("listInterestGroupDel", api_key, list_id(name), group_name)
      rescue XMLRPC::FaultException
        raise(MailChimpInterestGroupNotFoundError.new, "Interest Group not found")
      end
    end
    
    # Get all the information for a particular member of a list
    def list_member_info(name, email_address)
      name = list_name(name)
      xmlrpc_client.call("listMemberInfo", api_key, list_id(name), email_address.downcase)
    end
    
    # Get all of the list members for a list that are of a particular status
    def list_members(name, status = 'subscribed', start = "", limit = "")
      name = list_name(name)
      xmlrpc_client.call("listMembers", api_key, list_id(name), status, start, limit)
    end
    
    # Add a new merge tag to a given list
    def list_merge_var_add(name, tag, var_name, required = false)
      name = list_name(name)
      xmlrpc_client.call("listMergeVarAdd", api_key, list_id(name), tag.to_s.upcase, var_name, required)
    end
    
    # Delete a merge tag from a given list and all it's members
    def list_merge_var_del(name, tag)
      name = list_name(name)
      xmlrpc_client.call("listMergeVarDel", api_key, list_id(name), tag.to_s.upcase)
    end
    
    # Get the list of merge targs for a given list, including their name, tag, and required setting
    def list_merge_vars(name)
      name = list_name(name)
      xmlrpc_client.call("listMergeVars", api_key, list_id(name))
    end
    
    # Subscribe the provided email to a list
    def list_subscribe(name, email, *options)
      name = list_name(name)
      options = options.extract_options!
      email_type = options.delete(:email_type) || 'html'
      double_optin = options.delete(:double_optin) || false
      merge_vars = {}
      options.each { |key, value|
        merge_vars[key.to_s.upcase] = value
      }
      xmlrpc_client.call("listSubscribe", api_key, list_id(name), email.downcase, merge_vars, email_type, double_optin)
    end
    
    # Unsubscribe the given email address from the list
    def list_unsubscribe(name, email, delete_member = false, send_goodbye = false, send_notify = false)
      name = list_name(name)
      xmlrpc_client.call("listUnsubscribe", api_key, list_id(name), email.downcase, delete_member, send_goodbye, send_notify)
    end
    
    # Edit the email address, merge fields, and interest groups for a list member
    def list_update_member(name, email, *options)
      name = list_name(name)
      options = options.extract_options!
      email_type = options.delete(:email_type) || 'html'
      replace_interests = options.delete(:replace_interests) || true
      merge_vars = {}
      options.each { |key, value|
        merge_vars[key.to_s.upcase] = value
      }
      xmlrpc_client.call("listUpdateMember", api_key, list_id(name), email, merge_vars, email_type, replace_interests)
    end
    
    # Log into the MailChimp API and return an API key
    def login(username, password)
      @@api_key = xmlrpc_client.call("login", username, password)
    rescue => e
      raise(MailChimpLoginError.new, "Could not login to the MailChimp API using username: #{username} and password: #{password}. #{e.message}")
    end
    
  protected
    # Return the current API key or raise an error
    def api_key
      @@api_key || raise(MailChimpLoginError.new, "You are not connected to the MailChimp API")
    end
    
    # Get the list id from a list name
    def list_id(name)
      @@cached_lists ||= lists
      begin
        list_id = @@cached_lists.find {|list| list["name"] == name}["id"]
      rescue
        raise(MailChimpListNotFoundError.new, "Could not find the specified MailChimp List") and return
      end
    end
    
    # Convert a symbol to a list name
    def list_name(name)
      if name.is_a?(Symbol)
        return name.to_s.titleize
      end
      name
    end
  
    # Return an instance of the xml_rpc client for connecting to the mailchimp API
    def xmlrpc_client
      @@xmlrpc_client ||= XMLRPC::Client.new2("http://api.mailchimp.com/1.1/", nil, 180)
    end
  end
end