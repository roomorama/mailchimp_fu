Rails.application.routes.draw do
  match '/mailchimp/callback' => "mailchimp#callback", :as => 'mailchimp_unsubscribe'
end