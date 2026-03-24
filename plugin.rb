# name: discourse-communiteq-powertools
# about: Communiteq Powertools
# version: 2026.1
# authors: Communiteq
# url:

enabled_site_setting :communiteq_powertools_enabled

require_relative "lib/communiteq_powertools/discourse_templates_templates_serializer_extension"
require_relative "lib/communiteq_powertools/post_guardian_extension"

after_initialize do
  reloadable_patch do |plugin|
    DiscourseTemplates::TemplatesSerializer.prepend(CommuniteqPowertools::DiscourseTemplatesTemplatesSerializerExtension)
    Guardian.prepend(CommuniteqPowertools::ExtendPostGuardianTimeLimit)
  end
end
