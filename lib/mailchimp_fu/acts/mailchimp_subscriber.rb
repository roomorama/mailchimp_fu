require 'xmlrpc/client'
require 'mail_chimp'

module DonaldPiret
  module MailchimpFu

    # This module is mixed into the mailchimp list subscriber classes
    #
    # ==== Callbacks
    # *
    module MailchimpSubscriber

      begin
        Object.send(:include, Delayed::MessageSending)
        Module.send(:include, Delayed::MessageSending::ClassMethods)
      rescue Exception
        puts "Could not load delayed job"
      end

      def self.included(base)
        base.extend ClassMethods
        mattr_reader :mailchimp_config
        mattr_reader :mailchimp_apikey
        mattr_reader :mailchimp_enabled
        begin
          @@mailchimp_config = YAML.load(File.open("#{::Rails.root.to_s}/config/mailchimp_fu.yml"))[Rails.env.to_s].symbolize_keys rescue nil
          @@mailchimp_enabled = @@malchimp_config[:enabled] != false
          if @@mailchimp_enabled
            @@mailchimp_apikey = MailChimp.login(@@mailchimp_config[:username], @@mailchimp_config[:password])
          end
        rescue
        end
        base.instance_eval do
          after_create :after_mailchimp_subscriber_create
          after_update :before_mailchimp_subscriber_update
          after_destroy :after_mailchimp_subscriber_destroy
        end
      end

      # Merge vars method
      def mailchimp_merge_var(key)
        value = self.mailchimp_merge_vars[key]
        if value.is_a? Symbol
          self.send(value)
        else
          return value
        end
      end

      def mailchimp_merge_var_changed?(key)
        value = self.mailchimp_merge_vars[key]
        if value.is_a? Symbol
          self.respond_to?("#{value}_changed?") && self.send("#{value}_changed?")
        else
          return false
        end
      end

      def merge_vars_changed?
        changed = false
        self.mailchimp_merge_vars.each { |mv|
          changed ||= mailchimp_merge_var_changed?(mv) unless mailchimp_merge_var(mv).nil?
        }
      end

      # After subscriber created callback
      # Do initial list registration
      def after_mailchimp_subscriber_create
        wants_email = self.mailchimp_enabled_column ? self.send(self.mailchimp_enabled_column.to_sym) : true
        if wants_email
          logger.info "Calling MailChimpSubscriber subscribe after create"
          self.subscribe_to_mailchimp if @@mailchimp_enabled
        end
      end

      # Before subscriber update callback
      # Do list update
      def before_mailchimp_subscriber_update
        wants_email = self.mailchimp_enabled_column ? self.send(self.mailchimp_enabled_column.to_sym) : true
        wants_email_changed = self.mailchimp_enabled_column ? self.send((self.mailchimp_enabled_column.to_s + "_changed?").to_sym) : false
        if wants_email_changed
          if wants_email
            logger.info "Calling MailChimpSubscriber subscribe after update"
            self.subscribe_to_mailchimp if @@mailchimp_enabled
          else
            old_email = self.send("#{self.mailchimp_email_column}_was") || self.send("#{self.mailchimp_email_column}")
            logger.info "Calling MailChimpSubscriber unsubscribe after update"
            self.unsubscribe_from_mailchimp(old_email) if @@mailchimp_enabled
          end
        elsif wants_email
          email_changed = self.send("#{self.mailchimp_email_column}_changed?")
          if email_changed || merge_vars_changed?
            old_email = self.send("#{self.mailchimp_email_column}_was") || self.send("#{self.mailchimp_email_column}")
            logger.info "Calling MailchimpWorker Async Update after update"
            self.update_mailchimp_subscription(old_email) if @@mailchimp_enabled
          end
        end
      end

      # After subscriber destroy callback
      # Remove from list
      def after_mailchimp_subscriber_destroy
        logger.info "Calling MailchimpWorker Async Unsusbscribe after destroy"
        self.unsubscribe_from_mailchimp if @@mailchimp_enabled
      end

      def subscribe_to_mailchimp
        email_address = self.send(self.mailchimp_email_column.to_sym)
        merge_vars = {}
        self.mailchimp_merge_vars.each { |mv|
          merge_vars[mv.to_sym] = mailchimp_merge_var(mv) unless mailchimp_merge_var(mv).nil?
        }
        MailChimp.list_subscribe(self.mailchimp_list_name, email_address, merge_vars)
        logger.info "Called MailChimp.list_subscribe member on #{email_address}"
      rescue => e
        if e.message =~ /is already subscribed to list/
          # User is already subscribed to list, so update instead
          logger.info "Calling MailChimpSubscriber update after create"
          self.update_mailchimp_subscription
        elsif e.message.strip =~ /Invalid Email Address: (.+)/
          # Do nothing
        else
          raise e
        end
      end

      def update_mailchimp_subscription(old_email = nil)
        email_address = old_email || self.send(self.mailchimp_email_column.to_sym)
        merge_vars = {}
        self.mailchimp_merge_vars.each { |mv|
          merge_vars[mv.to_sym] = mailchimp_merge_var(mv) unless mailchimp_merge_var(mv).nil?
        }
        merge_vars = merge_vars.merge(:email => self.send(self.mailchimp_email_column.to_sym)) if old_email != self.send(self.mailchimp_email_column.to_sym)
        MailChimp.list_update_member(self.mailchimp_list_name, email_address, merge_vars)
        logger.info "Called MailChimp.list_update member on #{email_address}"
      rescue => e
        if e.message =~ /is already subscribed to list/
          # User is already subscribed to list, so update instead
          self.update_mailchimp_subscription(old_email)
        elsif e.message.strip =~ /^There is no record of "(.+)" in the database$/
          self.subscribe_to_mailchimp
        elsif e.message.strip =~ /^The email address "(.+)" does not belong to this list$/
          self.update_attribute(self.mailchimp_enabled_column.to_sym, false) if self.mailchimp_enabled_column
        else
          raise e
        end
      end

      def unsubscribe_from_mailchimp(old_email = nil)
        email_address = old_email || self.send(self.mailchimp_email_column.to_sym)
        MailChimp.list_unsubscribe(self.mailchimp_list_name, email_address)
        logger.info "Called MailChimp.list_unsubscribe member on #{email_address}"
      rescue => e
        if e.message.strip =~ /^There is no record of "(.+)" in the database$/
          # Do nothing
        elsif e.message.strip =~ /^(.+) is not subscribed to list (.+)$/
          # Do nothing
        else
          raise e
        end
      end

      if defined?(Delayed::MessageSending) && !Rails.env.test?
        handle_asynchronously :subscribe_to_mailchimp
        handle_asynchronously :update_mailchimp_subscription
        handle_asynchronously :unsubscribe_from_mailchimp
      end

      module ClassMethods

      end
    end
  end
end