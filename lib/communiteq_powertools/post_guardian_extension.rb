# frozen_string_literal: true

module CommuniteqPowertools
  module ExtendPostGuardianTimeLimit
    def can_delete_post?(post)
      s = super
      return s unless SiteSetting.communiteq_powertools_enabled && SiteSetting.communiteq_powertools_post_delete_time_limit_enabled
      return false unless s # we impose an EXTRA restriction so false stays false
      # taken from https://github.com/discourse/discourse/blob/f5194aadd39d5c323df52a346c6641e49d3279c5/lib/guardian/post_guardian.rb#L196-L199
      if is_my_own?(post)
        return true if post.user_deleted && !post.deleted_at
        return false if (Time.now - (SiteSetting.communiteq_powertools_post_delete_time_limit_hours * 3600)) > post.created_at
      end
      true
    end
  end
end