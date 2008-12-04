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
    def list_members(name, status = 'subscribed', start = 0, limit = 100)
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
      options.each do { |key, value|
        merge_vars[key.to_s.upcase] = value
      }
      xmlrpc_client.call("listSubscribe", api_key, list_id(name), email.downcase, merge_vars, email_type, double_optin)
    end
    
    # Unsubscribe the given email address from the list
    def list_unsubscribe(name, email, delete_member = true, send_goodbye = false, send_notify = false)
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
      options.each do { |key, value|
        merge_vars[key.to_s.upcase] = value
      }
      xmlrpc_client.call("listUpdateMember", api_key, list_id(name), email, merge_vars, email_type, replace_interests)
    end
    
    # Log into the MailChimp API and return an API key
    def login(username, password)
      @@api_key = xmlrpc_client.call("login", username, password)
    rescue
      raise(MailChimpLoginError.new, "Could not login to the MailChimp API using username: #{username} and password: #{password}")
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
      @@xmlrpc_client ||= XMLRPC::Client.new2("http://api.mailchimp.com/1.1/")
    end
  end
end