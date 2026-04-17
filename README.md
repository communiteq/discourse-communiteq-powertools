# Communiteq Powertools Plugin

A comprehensive admin interface for managing advanced Discourse settings and features.

## Features

- **Custom Admin Interface**: Dedicated admin page accessible from the Advanced section of the admin sidebar
- **Tabbed Navigation**: Organize settings into logical tabs (General, Posting, etc.)
- **Toggle Switches**: Modern toggle switches for boolean settings (like the installed plugins screen)
- **Number Inputs**: Support for numeric settings with validation
- **Rich Descriptions**: Detailed help text for each setting to guide administrators
- **Hidden Settings**: All powertools settings are hidden from the standard admin interface and only accessible through the Powertools UI

## Current Features

### General Tab
- **Sort Templates Alphabetically**: When enabled, Templates will display in alphabetical order instead of by most recent usage

### Posting Tab
- **Post Deletion Time Limit (Enabled)**: Toggle to enforce a time limit on post deletions
- **Post Deletion Time Limit (Hours)**: Set the window (in hours) during which users can delete their own posts after creation

## Extending the Plugin

### Adding New Settings

1. **Add the setting to `config/settings.yml`**:
```yaml
communiteq_powertools:
  communiteq_powertools_your_new_setting:
    default: false
    client: false
    hidden: true  # Hide it from standard admin interface
```

2. **Add translations to `config/locales/en.yml`**:
```yaml
admin:
  communiteq_powertools:
    your_new_setting: "Your Setting Label"
    your_new_setting_description: |
      Detailed description of what this setting does.
      Can span multiple lines.
```

3. **Update `app/controllers/admin/communiteq_powertools_controller.rb`**:
Add your setting to the `get_features_config` method:
```ruby
{
  key: "your_new_setting",
  label: I18n.t("admin.communiteq_powertools.your_new_setting"),
  description: I18n.t("admin.communiteq_powertools.your_new_setting_description"),
  value: SiteSetting.communiteq_powertools_your_new_setting,
  type: "toggle"  # or "number" for numeric settings
}
```

4. **Implement the backend logic** in your extensions (similar to how `post_guardian_extension.rb` works)

### Creating New Tabs

To add a new tab, modify the `get_features_config` method in the controller:

```ruby
{
  id: "your-tab",
  name: I18n.t("admin.communiteq_powertools.tabs.your_tab"),
  description: I18n.t("admin.communiteq_powertools.tabs.your_tab_description"),
  settings: [
    # Add your settings here
  ]
}
```

### Setting Types

- **toggle**: Boolean toggle switch
  - `value`: true/false
  - Renders as a toggle switch

- **number**: Numeric input
  - `value`: integer/float
  - Renders as a number input field
  - Optional: `depends_on: "other_setting_key"` to disable unless another toggle is enabled

## Architecture

### Backend
- **Controller**: `app/controllers/admin/communiteq_powertools_controller.rb`
  - Handles fetching configuration and updating settings
  - Returns JSON with features, settings, and current values

### Frontend
- **Component**: `app/assets/javascripts/discourse/components/communiteq-powertools-admin.js`
  - Handles tab navigation
  - Manages setting updates
  - Shows toast notifications for success/error
  - Handles dependent settings (e.g., disable a field if its dependency is off)

- **Template**: `app/assets/javascripts/discourse/templates/admin/communiteq-powertools.hbs`
  - Renders tabs and settings
  - Uses Discourse's ToggleSwitch component for boolean settings
  - Standard HTML inputs for numbers

- **Styles**: `app/assets/stylesheets/communiteq-powertools-admin.scss`
  - Consistent with Discourse admin styling
  - Mobile responsive

## Implementation Details

### Hidden Settings
Settings are hidden from the standard admin interface by adding `hidden: true` to the YAML definition. Users must use the Powertools admin panel to modify these settings.

### CSRF Protection
All POST requests include proper CSRF tokens from the page meta tags.

### Type Conversion
The controller automatically converts string parameters to appropriate types (boolean, integer) based on the setting type.

## Usage

1. Enable the plugin in your Discourse instance
2. Enable the "communiteq powertools enabled" setting
3. Navigate to Admin → Advanced → Communiteq Powertools
4. Use the tabs to navigate between feature groups
5. Toggle switches or modify numeric values
6. Changes are saved immediately with visual feedback

## API

### GET `/admin/communiteq-powertools.json`
Returns the current configuration and all settings values.

**Response**:
```json
{
  "features": [
    {
      "id": "general",
      "name": "General",
      "description": "General site settings...",
      "settings": [
        {
          "key": "sort_templates_alphabetically",
          "label": "Sort Templates Alphabetically",
          "description": "When enabled...",
          "value": false,
          "type": "toggle"
        }
      ]
    }
  ],
  "enabled": true
}
```

### POST `/admin/communiteq-powertools`
Updates a setting value.

**Parameters**:
- `feature` (string): The tab ID
- `setting_name` (string): The setting key (without prefix)
- `value` (string/boolean/number): The new value

**Response**:
```json
{
  "success": true
}
```

## Contributing

To add new features to this plugin:
1. Create the setting in `settings.yml`
2. Add translations for the UI
3. Add the setting configuration to the controller
4. Implement the backend logic that uses the setting
5. Document your addition in this README
