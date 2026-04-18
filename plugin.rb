# name: discourse-communiteq-powertools
# about: Communiteq Powertools
# version: 2026.1
# authors: Communiteq
# url: https://github.com/communiteq/discourse-communiteq-powertools

enabled_site_setting :communiteq_powertools_enabled

require_relative "lib/communiteq_powertools/engine"
require_relative "lib/communiteq_powertools/discourse_templates_templates_serializer_extension"
require_relative "lib/communiteq_powertools/new_post_manager_extension"
require_relative "lib/communiteq_powertools/post_guardian_extension"
require_relative "lib/communiteq_powertools/settings_filter"

register_asset "stylesheets/communiteq-powertools-admin.scss"
add_admin_route("communiteq_powertools.title", "discourse-communiteq-powertools", { use_new_show_route: true })

after_initialize do
  reloadable_patch do |plugin|
    DiscourseTemplates::TemplatesSerializer.prepend(CommuniteqPowertools::DiscourseTemplatesTemplatesSerializerExtension)
    NewPostManager.singleton_class.prepend(CommuniteqPowertools::ForceModerationByGroups)
    Guardian.prepend(CommuniteqPowertools::ExtendPostGuardianTimeLimit)
  end

  # JSON endpoints consumed by the admin plugin page.
  Discourse::Application.routes.append do
    # Back the Ember sub-routes so a browser refresh doesn't 404
    get "/admin/plugins/discourse-communiteq-powertools/about" => "admin/plugins#show",
        constraints: AdminConstraint.new
    get "/admin/plugins/discourse-communiteq-powertools/general" => "admin/plugins#show",
        constraints: AdminConstraint.new
    get "/admin/plugins/discourse-communiteq-powertools/posting" => "admin/plugins#show",
        constraints: AdminConstraint.new

    # API lives outside /admin/plugins/ to avoid wildcard conflicts with core routes
    get "/admin/communiteq-powertools/config" => "admin/communiteq_powertools#index",
        constraints: AdminConstraint.new, defaults: { format: :json }
    post "/admin/communiteq-powertools/config" => "admin/communiteq_powertools#update",
        constraints: AdminConstraint.new, defaults: { format: :json }
    post "/admin/communiteq-powertools/acknowledge" => "admin/communiteq_powertools#acknowledge",
        constraints: AdminConstraint.new, defaults: { format: :json }
  end
end
