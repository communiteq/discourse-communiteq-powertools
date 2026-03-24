# frozen_string_literal: true

module CommuniteqPowertools
  module DiscourseTemplatesTemplatesSerializerExtension
    def usages
      return super unless SiteSetting.communiteq_powertools_enabled &&
        SiteSetting.communiteq_powertools_sort_templates_alphabetically
      0
    end
  end
end