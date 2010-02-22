ActionController::Routing::Routes.draw do |map|
  map.mailchimp_unsubscribe '/mailchimp/callback', :controller => 'mailchimp', :action => 'callback'#, :conditions => { :method => :post }
end