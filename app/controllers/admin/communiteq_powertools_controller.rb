# frozen_string_literal: true

class Admin::CommuniteqPowertoolsController < Admin::AdminController
  def index
    render json: {
      features: get_features_config,
      enabled: SiteSetting.communiteq_powertools_enabled
    }
  end

  def update
    setting_name = params[:setting_name]
    value = params[:value]

    # Convert string values to appropriate types
    value = case value
            when "true", true
              true
            when "false", false
              false
            when /^\d+$/
              value.to_i
            else
              value
            end

    setting_key = "communiteq_powertools_#{setting_name}".to_sym
    
    if SiteSetting.respond_to?(setting_key)
      begin
        SiteSetting.set(setting_key, value)
        render json: { success: true }
      rescue => e
        render json: { error: e.message }, status: 400
      end
    else
      render json: { error: "Invalid setting" }, status: 400
    end
  end

  private

  def get_features_config
    [
      {
        id: "general",
        name: I18n.t("admin.communiteq_powertools.tabs.general"),
        description: I18n.t("admin.communiteq_powertools.tabs.general_description"),
        settings: [
          {
            key: "sort_templates_alphabetically",
            label: "admin.communiteq_powertools.sort_templates_alphabetically",
            description: "admin.communiteq_powertools.sort_templates_alphabetically_description",
            value: SiteSetting.communiteq_powertools_sort_templates_alphabetically,
            type: "toggle"
          }
        ]
      },
      {
        id: "posting",
        name: I18n.t("admin.communiteq_powertools.tabs.posting"),
        description: I18n.t("admin.communiteq_powertools.tabs.posting_description"),
        settings: [
          {
            key: "post_delete_time_limit_enabled",
            label: "admin.communiteq_powertools.post_delete_time_limit_enabled",
            description: "admin.communiteq_powertools.post_delete_time_limit_enabled_description",
            value: SiteSetting.communiteq_powertools_post_delete_time_limit_enabled,
            type: "toggle"
          },
          {
            key: "post_delete_time_limit_hours",
            label: "admin.communiteq_powertools.post_delete_time_limit_hours",
            description: "admin.communiteq_powertools.post_delete_time_limit_hours_description",
            value: SiteSetting.communiteq_powertools_post_delete_time_limit_hours,
            type: "number",
            depends_on: "post_delete_time_limit_enabled"
          }
        ]
      }
    ]
  end
end
