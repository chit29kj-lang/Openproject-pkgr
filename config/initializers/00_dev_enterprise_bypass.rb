# frozen_string_literal: true

if Rails.env.development?
  Rails.application.config.to_prepare do
    # Patches EnterpriseToken to always allow everything in development
    EnterpriseToken.class_eval do
      def self.allows_to?(_feature)
        true
      end

      def self.active?
        true
      end

      def self.show_banners?
        false
      end
    end
  end
end
