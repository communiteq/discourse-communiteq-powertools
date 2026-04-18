# frozen_string_literal: true

class Admin::CommuniteqPowertoolsController < Admin::AdminController
  FEATURE_SETTING_SCHEMAS = {
    general: [
      {
        key: "sort_templates_alphabetically",
        section: "templates",
        section_title: "admin.communiteq_powertools.templates_heading",
        label: "admin.communiteq_powertools.sort_templates_alphabetically",
        description: "admin.communiteq_powertools.sort_templates_alphabetically_description",
        locked_hint: "admin.communiteq_powertools.templates_plugin_required",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "max_category_nesting",
        site_setting_key: "max_category_nesting",
        section: "category_structure",
        section_title: "admin.communiteq_powertools.category_structure_heading",
        label: "admin.communiteq_powertools.max_category_nesting",
        description: "admin.communiteq_powertools.max_category_nesting_description",
        type: "category_nesting_toggle",
        locked_hint: "admin.communiteq_powertools.max_category_nesting_requires_flattening",
        validation: "category_nesting"
      },
      {
        key: "enable_badge_sql",
        site_setting_key: "enable_badge_sql",
        section: "badge_sql",
        section_title: "admin.communiteq_powertools.badge_sql_heading",
        label: "admin.communiteq_powertools.enable_badge_sql",
        description: "admin.communiteq_powertools.enable_badge_sql_description",
        type: "toggle",
        validation: "boolean"
      }
    ],
    posting: [
      {
        key: "auto_auto_grid_enabled",
        section: "auto_auto_grid",
        section_title: "admin.communiteq_powertools.auto_auto_grid_heading",
        label: "admin.communiteq_powertools.auto_auto_grid_enabled",
        description: "admin.communiteq_powertools.auto_auto_grid_enabled_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "auto_auto_grid_min_images",
        section: "auto_auto_grid",
        section_title: "admin.communiteq_powertools.auto_auto_grid_heading",
        label: "admin.communiteq_powertools.auto_auto_grid_min_images",
        description: "admin.communiteq_powertools.auto_auto_grid_min_images_description",
        type: "number",
        depends_on: "auto_auto_grid_enabled",
        validation: "non_negative_integer"
      },
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
      },
      {
        key: "force_moderation_new_topics_for_groups",
        section: "force_moderation_by_groups",
        section_title: "admin.communiteq_powertools.force_moderation_by_groups_heading",
        label: "admin.communiteq_powertools.force_moderation_new_topics_for_groups",
        description: "admin.communiteq_powertools.force_moderation_new_topics_for_groups_description",
        type: "group_list",
        validation: "group_list"
      },
      {
        key: "force_moderation_for_groups",
        section: "force_moderation_by_groups",
        section_title: "admin.communiteq_powertools.force_moderation_by_groups_heading",
        label: "admin.communiteq_powertools.force_moderation_for_groups",
        description: "admin.communiteq_powertools.force_moderation_for_groups_description",
        type: "group_list",
        validation: "group_list"
      }
    ],
    logging: [
      {
        key: "ai_translation_verbose_logs",
        site_setting_key: "ai_translation_verbose_logs",
        section: "plugin_logging",
        section_title: "admin.communiteq_powertools.logging_plugin_heading",
        label: "admin.communiteq_powertools.ai_translation_verbose_logs",
        description: "admin.communiteq_powertools.ai_translation_verbose_logs_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "oauth2_debug_auth",
        site_setting_key: "oauth2_debug_auth",
        section: "plugin_logging",
        section_title: "admin.communiteq_powertools.logging_plugin_heading",
        label: "admin.communiteq_powertools.oauth2_debug_auth",
        description: "admin.communiteq_powertools.oauth2_debug_auth_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "openid_connect_verbose_logging",
        site_setting_key: "openid_connect_verbose_logging",
        section: "plugin_logging",
        section_title: "admin.communiteq_powertools.logging_plugin_heading",
        label: "admin.communiteq_powertools.openid_connect_verbose_logging",
        description: "admin.communiteq_powertools.openid_connect_verbose_logging_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "discourse_id_verbose_logging",
        site_setting_key: "discourse_id_verbose_logging",
        section: "core_logging",
        section_title: "admin.communiteq_powertools.logging_core_heading",
        label: "admin.communiteq_powertools.discourse_id_verbose_logging",
        description: "admin.communiteq_powertools.discourse_id_verbose_logging_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "verbose_upload_logging",
        site_setting_key: "verbose_upload_logging",
        section: "core_logging",
        section_title: "admin.communiteq_powertools.logging_core_heading",
        label: "admin.communiteq_powertools.verbose_upload_logging",
        description: "admin.communiteq_powertools.verbose_upload_logging_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "verbose_auth_token_logging",
        site_setting_key: "verbose_auth_token_logging",
        section: "core_logging",
        section_title: "admin.communiteq_powertools.logging_core_heading",
        label: "admin.communiteq_powertools.verbose_auth_token_logging",
        description: "admin.communiteq_powertools.verbose_auth_token_logging_description",
        type: "toggle",
        validation: "boolean"
      },
      {
        key: "site_setting_verbose_client_logging",
        site_setting_key: "site_setting_verbose_client_logging",
        section: "core_logging",
        section_title: "admin.communiteq_powertools.logging_core_heading",
        label: "admin.communiteq_powertools.site_setting_verbose_client_logging",
        description: "admin.communiteq_powertools.site_setting_verbose_client_logging_description",
        type: "toggle",
        validation: "boolean"
      }
    ]
  }.freeze

  def index
    render json: {
      features: get_features_config,
      enabled: SiteSetting.communiteq_powertools_enabled,
      acknowledged: current_user.custom_fields["communiteq_powertools_acknowledged"] == "true"
    }
  end

  def acknowledge
    current_user.custom_fields["communiteq_powertools_acknowledged"] = "true"
    current_user.save_custom_fields(true)
    render json: { success: true }
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

    setting_key = site_setting_key_for(schema).to_sym

    if SiteSetting.respond_to?(setting_key)
      begin
        prev_value = SiteSetting.public_send(setting_key)
        SiteSetting.set(setting_key, value)
        StaffActionLogger.new(current_user).log_site_setting_change(
          setting_key,
          prev_value,
          value,
          { context: "Communiteq Powertools" }
        )
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
    when "number", "category_nesting_toggle"
      raw_value.to_i
    when "group_list"
      if raw_value.is_a?(Array)
        raw_value.map(&:to_s).reject(&:blank?).join("|")
      else
        raw_value.to_s
      end
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
    when "category_nesting"
      [2, 3].include?(value) && (value == 3 || !third_level_categories_exist?)
    when "group_list"
      value.blank? || value.match?(/\A\d+(\|\d+)*\z/)
    else
      true
    end
  end

  def site_setting_key_for(schema)
    schema[:site_setting_key].presence || "communiteq_powertools_#{schema[:key]}"
  end

  def third_level_categories_exist?
    Category.joins(parent_category: :parent_category).exists?
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
      },
      {
        id: "logging",
        name: I18n.t("admin.communiteq_powertools.tabs.logging"),
        description: I18n.t("admin.communiteq_powertools.tabs.logging_description"),
        settings: settings_for(:logging)
      }
    ]
  end

  def settings_for(feature)
    FEATURE_SETTING_SCHEMAS.fetch(feature).map do |schema|
      extra = {}
      if schema[:validation] == "category_nesting"
        extra[:locked] = SiteSetting.max_category_nesting == 3 && third_level_categories_exist?
      end
      if schema[:key] == "sort_templates_alphabetically"
        extra[:locked] = !templates_plugin_enabled?
      end
      if schema[:key] == "ai_translation_verbose_logs"
        extra[:locked] = !plugin_enabled?("discourse-ai")
        extra[:locked_hint] = "admin.communiteq_powertools.logging_requires_ai"
      end
      if schema[:key] == "oauth2_debug_auth"
        extra[:locked] = !plugin_enabled?("discourse-oauth2-basic")
        extra[:locked_hint] = "admin.communiteq_powertools.logging_requires_oauth2"
      end
      if schema[:key] == "openid_connect_verbose_logging"
        extra[:locked] = !plugin_enabled?("discourse-openid-connect")
        extra[:locked_hint] = "admin.communiteq_powertools.logging_requires_openid"
      end
      key = site_setting_key_for(schema)
      value = SiteSetting.respond_to?(key) ? SiteSetting.public_send(key) : false
      schema.merge(value:).merge(extra)
    end
  end

  def plugin_enabled?(name)
    plugin = Discourse.plugins_by_name[name]
    plugin&.enabled? || false
  end

  def templates_plugin_enabled?
    plugin = Discourse.plugins_by_name["discourse-templates"]
    plugin&.enabled? || false
  end
end
