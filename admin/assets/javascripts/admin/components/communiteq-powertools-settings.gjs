import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { eq } from "truth-helpers";
import DToggleSwitch from "discourse/components/d-toggle-switch";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import GroupChooser from "discourse/select-kit/components/group-chooser";
import { i18n } from "discourse-i18n";

export default class CommuniteqPowertoolsSettings extends Component {
  @service site;
  @service toasts;

  @tracked settings = [];

  isDisabled = (setting) => {
    if (setting.locked) {
      return true;
    }
    if (!setting.depends_on) {
      return false;
    }
    const dep = this.settings.find((s) => s.key === setting.depends_on);
    return !dep?.value;
  };

  constructor(owner, args) {
    super(owner, args);
    this.settings = [...(args.tab?.settings ?? [])];
  }

  get settingSections() {
    const sections = [];
    const grouped = new Map();

    this.settings.forEach((setting) => {
      const key = setting.section || "__default";
      if (!grouped.has(key)) {
        grouped.set(key, {
          id: key,
          title: setting.section_title,
          settings: [],
        });
        sections.push(grouped.get(key));
      }
      grouped.get(key).settings.push(setting);
    });

    return sections;
  }

  @action
  async toggle(setting) {
    await this.save(setting, !setting.value);
  }

  @action
  async updateInput(setting, event) {
    const raw = event.target.value.trim();

    const validation = setting.validation;
    if (validation === "non_negative_integer") {
      if (!/^\d+$/.test(raw)) {
        event.target.value = setting.value;
        this.toasts.error({
          duration: 3500,
          data: {
            message: i18n(
              "admin.communiteq_powertools.non_negative_integer_required"
            ),
          },
        });
        return;
      }

      const val = parseInt(raw, 10);
      await this.save(setting, val);
      return;
    }

    await this.save(setting, raw);
  }

  @action
  async toggleCategoryNesting(setting) {
    const newValue = setting.value === 3 ? 2 : 3;
    await this.save(setting, newValue);
  }

  @action
  async updateSelect(setting, event) {
    const raw = event.target.value;
    const value =
      setting.validation === "category_nesting" ? parseInt(raw, 10) : raw;
    await this.save(setting, value);
  }

  groupListValue(setting) {
    if (Array.isArray(setting.value)) {
      return setting.value;
    }

    const raw = setting.value?.toString() || "";
    if (!raw.length) {
      return [];
    }

    return raw
      .split("|")
      .filter(Boolean)
      .map((id) => parseInt(id, 10));
  }

  @action
  async updateGroupList(setting, selectedGroupIds) {
    const normalized = (selectedGroupIds || [])
      .map((id) => id?.toString())
      .filter(Boolean)
      .join("|");

    await this.save(setting, normalized);
  }

  async save(setting, newValue) {
    const old = setting.value;
    // Optimistically update so the toggle reflects immediately
    this.settings = this.settings.map((s) =>
      s.key === setting.key ? { ...s, value: newValue } : s
    );
    try {
      await ajax("/admin/communiteq-powertools/config", {
        type: "POST",
        data: {
          feature: this.args.tab?.id,
          setting_name: setting.key,
          value: newValue,
        },
      });
      this.toasts.success({
        duration: 2000,
        data: { message: i18n("saved") },
      });
    } catch (error) {
      // Revert on failure
      this.settings = this.settings.map((s) =>
        s.key === setting.key ? { ...s, value: old } : s
      );

      if (setting.validation === "category_nesting") {
        this.toasts.error({
          duration: 4000,
          data: {
            message: i18n(
              "admin.communiteq_powertools.max_category_nesting_requires_flattening"
            ),
          },
        });
      }

      popupAjaxError(error);
    }
  }

  <template>
    <div class="communiteq-powertools-settings admin-config-area__settings">
      {{#each this.settingSections as |section|}}
        <div class="cpt-settings-section">
          {{#if section.title}}
            <h3 class="cpt-settings-section__title">{{i18n section.title}}</h3>
          {{/if}}

          {{#each section.settings as |setting|}}
            <div
              class="cpt-setting-row
                {{if (this.isDisabled setting) 'cpt-setting-row--disabled'}}
                {{if setting.locked 'cpt-setting-row--locked'}}"
            >
              <div class="cpt-setting-row__content">
                <label class="cpt-setting-row__label">{{i18n
                    setting.label
                  }}</label>
                {{#if setting.description}}
                  <p class="cpt-setting-row__description">{{i18n
                      setting.description
                    }}</p>
                {{/if}}
              </div>
              <div class="cpt-setting-row__control">
                {{#if (eq setting.type "toggle")}}
                  <DToggleSwitch
                    @state={{setting.value}}
                    disabled={{this.isDisabled setting}}
                    {{on "click" (fn this.toggle setting)}}
                  />
                {{else if (eq setting.type "number")}}
                  <input
                    type="text"
                    inputmode="numeric"
                    pattern="[0-9]*"
                    value={{setting.value}}
                    disabled={{this.isDisabled setting}}
                    {{on "change" (fn this.updateInput setting)}}
                    class="cpt-number-input"
                  />
                {{else if (eq setting.type "category_nesting_toggle")}}
                  <DToggleSwitch
                    @state={{eq setting.value 3}}
                    disabled={{setting.locked}}
                    {{on "click" (fn this.toggleCategoryNesting setting)}}
                  />
                {{else if (eq setting.type "group_list")}}
                  <GroupChooser
                    @content={{this.site.groups}}
                    @value={{this.groupListValue setting}}
                    @onChange={{fn this.updateGroupList setting}}
                    disabled={{this.isDisabled setting}}
                  />
                {{else if (eq setting.type "select")}}
                  <select
                    class="cpt-select-input"
                    disabled={{this.isDisabled setting}}
                    {{on "change" (fn this.updateSelect setting)}}
                  >
                    {{#each setting.choices as |choice|}}
                      <option
                        value={{choice.value}}
                        selected={{eq choice.value setting.value}}
                      >
                        {{i18n choice.label}}
                      </option>
                    {{/each}}
                  </select>
                {{/if}}
              </div>
            </div>
            {{#if setting.locked}}
              <p class="cpt-setting-locked-hint">{{i18n
                  setting.locked_hint
                }}</p>
            {{/if}}
          {{/each}}
        </div>
      {{/each}}
    </div>
  </template>
}
