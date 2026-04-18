# frozen_string_literal: true

module CommuniteqPowertools
  module ForceModerationByGroups
    def post_needs_approval?(manager)
      super_result = super

      return super_result unless SiteSetting.communiteq_powertools_enabled
      return super_result unless super_result == :skip

      user = manager.user
      return super_result if user.blank? || user.staff? || user.staged?

      if (
           manager.args[:title].present? &&
             user.in_any_groups?(SiteSetting.communiteq_powertools_force_moderation_new_topics_for_groups_map)
         )
        return :new_topics_unless_allowed_groups
      end

      if user.in_any_groups?(SiteSetting.communiteq_powertools_force_moderation_for_groups_map)
        return :group
      end

      :skip
    end
  end
end
