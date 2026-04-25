# Communiteq Powertools Plugin

A comprehensive admin interface for managing advanced Discourse settings and features.

![Communiteq Powertools Banner](public/images/powertools-banner.png)

## Features

- **Custom Admin Interface**: Dedicated admin page accessible from the Advanced section of the admin sidebar
- **Acknowledgement Gate**: General, Posting, and Logging tabs are hidden until the admin confirms the About disclaimer
- **Tabbed Navigation**: About, General, Posting, and Logging tabs for structured administration
- **Schema-Driven Settings UI**: Toggle, numeric, category nesting, and group-list controls with validation, dependencies, and lock states
- **Plugin-Aware Locking**: Settings can be disabled when required plugins are not installed/enabled (for example AI, OAuth2, OpenID Connect)
- **Hidden Settings Management**: Powertools-managed settings are hidden from regular admin settings and edited through this UI
- **Server-Side Auto Image Grid**: Optional post-creation hook that auto-wraps consecutive image uploads in `[grid]...[/grid]`, tolerates whitespace, skips non-images, and does not rewrap existing grid blocks
- **Staff Action Logging**: Setting updates are recorded in admin logs as site setting changes
- **Rich Feedback**: Inline validation and success/error toasts during updates

## Current Features

### About Tab
- **Acknowledgement Workflow**: Shows plugin disclaimer and requires explicit acknowledgement before other tabs are shown

### General Tab
- **Sort Templates Alphabetically**: When enabled, Templates will display in alphabetical order instead of by most recent usage
- **Enable 3-level category nesting**: Toggle `max_category_nesting` between 2 and 3 with safeguards when third-level categories exist
- **Enable badge SQL**: Toggle SQL-based badge query capability
- **Allow embedding site in an iframe**: Toggle `allow_embedding_site_in_an_iframe` for iframe embedding scenarios

### Posting Tab
- **Auto Auto Grid (Enabled)**: Toggle server-side auto-grid wrapping for uploaded images during post creation
- **Auto Auto Grid (Min Images)**: Minimum consecutive image uploads required before wrapping in a grid block
- **Post Deletion Time Limit (Enabled)**: Toggle to enforce a time limit on post deletions
- **Post Deletion Time Limit (Hours)**: Set the window (in hours) during which users can delete their own posts after creation
- **Force moderation for new topics by groups**: Group-list based moderation requirement for new topics
- **Force moderation for groups**: Group-list based moderation requirement for all posts/replies

### Logging Tab
- **AI Translation Verbose Logs** (locked unless discourse-ai is enabled)
- **OAuth2 Debug Auth** (locked unless discourse-oauth2-basic is enabled)
- **OpenID Connect Verbose Logging** (locked unless discourse-openid-connect is enabled)
- **Discourse ID Verbose Logging**
- **Verbose Upload Logging**
- **Verbose Auth Token Logging**
- **Site Setting Verbose Client Logging**

## Usage

1. Enable the plugin in your Discourse instance
2. Enable the "communiteq powertools enabled" setting
3. Navigate to Admin → Advanced → Communiteq Powertools
4. Use the tabs to navigate between feature groups
5. Toggle switches or modify numeric values
6. Changes are saved immediately with visual feedback

## API

All endpoints below require an admin session.

### GET `/admin/communiteq-powertools/config.json`
Returns tab configuration, setting metadata/current values, plugin enabled status, and acknowledgement state.

**Response**:
```json
{
  "features": [
    {
      "id": "general",
      "name": "General",
      "description": "General site settings and template options",
      "settings": [
        {
          "key": "sort_templates_alphabetically",
          "section": "templates",
          "section_title": "admin.communiteq_powertools.templates_heading",
          "label": "admin.communiteq_powertools.sort_templates_alphabetically",
          "description": "admin.communiteq_powertools.sort_templates_alphabetically_description",
          "value": false,
          "type": "toggle",
          "validation": "boolean",
          "locked": false
        }
      ]
    }
  ],
  "enabled": true,
  "acknowledged": false
}
```

### POST `/admin/communiteq-powertools/config.json`
Updates one setting value.

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

**Validation Errors**:
- `400` for invalid setting names or save failures
- `422` for invalid values

### POST `/admin/communiteq-powertools/acknowledge.json`
Marks the current admin user as having acknowledged the About disclaimer.

**Response**:
```json
{
  "success": true
}
```

