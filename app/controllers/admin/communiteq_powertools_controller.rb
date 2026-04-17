# frozen_string_literal: true

class Admin::CommuniteqPowertoolsController < Admin::AdminController
  FEATURE_SETTING_SCHEMAS = {
    general: [
      {
        key: "sort_templates_alphabetically",
        label: "admin.communiteq_powertools.sort_templates_alphabetically",
        description: "admin.communiteq_powertools.sort_templates_alphabetically_description",
        type: "toggle",
        validation: "boolean"
      }
    ],
    posting: [
      {
        key: "post_delete_time_limit_enabled",
        section: "post_deletion_time_limit",
        section_title: "admin.communiteq_powertools.post_deletion_time_limit_heading",
        label: "admin.communiteq_powertools.post_delete_time_limit_enabled",
        description: "admin.communiteq_powertools.post_delete_time_limit_enabled_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "post_delete_time_limit_hours",
        section: "post_deletion_time_limit",
        section_title: "admin.communiteq_powertools.post_deletion_time_limit_heading",
        label: "admin.communiteq_powertools.post_delete_time_limit_hours",
        description: "admin.communiteq_powertools.post_delete_time_limit_hours_description",
        type: "number",
        depends_on: "post_delete_time_limit_enabled",
        validation: "non_negative_integer"
      }
    ]
  }.freeze

  def index
    render json: {
      features: get_features_config,
      enabled: SiteSetting.communiteq_powertools_enabled
    }
  end

  def update
    setting_name = params[:setting_name]
    feature_id = params[:feature]&.to_sym
    schema = setting_schema_for(setting_name, feature_id)

    if schema.blank?
      render json: { error: "Invalid setting" }, status: 400
      return
    end

    value = cast_value(params[:value], schema[:type])

    unless valid_setting_value?(value, schema[:validation])
      render json: { error: "Invalid setting value" }, status: 422
      return
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

  def setting_schema_for(setting_name, feature_id = nil)
    scope = feature_id.present? ? [feature_id] : FEATURE_SETTING_SCHEMAS.keys

    scope.each do |feature|
      schema = FEATURE_SETTING_SCHEMAS.fetch(feature, []).find { |entry| entry[:key] == setting_name }
      return schema if schema.present?
    end

    nil
  end

  def cast_value(raw_value, type)
    case type
    when "toggle"
      raw_value == true || raw_value == "true"
    when "number"
      raw_value.to_i
    else
      raw_value
    end
  end

  def valid_setting_value?(value, validation)
    case validation
    when "boolean"
      value == true || value == false
    when "non_negative_integer"
      value.is_a?(Integer) && value >= 0
    else
      true
    end
  end

  def get_features_config
    [
      {
        id: "general",
        name: I18n.t("admin.communiteq_powertools.tabs.general"),
        description: I18n.t("admin.communiteq_powertools.tabs.general_description"),
        settings: settings_for(:general)
      },
      {
        id: "posting",
        name: I18n.t("admin.communiteq_powertools.tabs.posting"),
        description: I18n.t("admin.communiteq_powertools.tabs.posting_description"),
        settings: settings_for(:posting)
      }
    ]
  end

  def settings_for(feature)
    FEATURE_SETTING_SCHEMAS.fetch(feature).map do |schema|
      schema.merge(
        value: SiteSetting.public_send("communiteq_powertools_#{schema[:key]}")
      )
    end
  end
end
