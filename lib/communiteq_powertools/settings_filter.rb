# frozen_string_literal: true

module CommuniteqPowertools
  module SettingsFilter
    def self.filter_settings(settings)
      # Hide communiteq powertools settings from the standard admin interface
      hidden_settings = %w[
        communiteq_powertools_sort_templates_alphabetically
        communiteq_powertools_post_delete_time_limit_enabled
        communiteq_powertools_post_delete_time_limit_hours
      ]

      settings.reject do |key, _value|
        hidden_settings.include?(key.to_s)
      end
    end
  end
end
