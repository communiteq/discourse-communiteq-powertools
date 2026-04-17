import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { inject as service } from "@ember/service";
import Component from "@glimmer/component";
import DToggleSwitch from "discourse/components/d-toggle-switch";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import eq from "truth-helpers/helpers/eq";
import { i18n } from "discourse-i18n";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";

export default class CommuniteqPowertoolsSettings extends Component {
  @service toasts;
  @tracked settings = [];

  constructor(owner, args) {
    super(owner, args);
    this.settings = [...(args.tab?.settings ?? [])];
  }

  isDisabled = (setting) => {
    if (!setting.depends_on) {
      return false;
    }
    const dep = this.settings.find((s) => s.key === setting.depends_on);
    return !dep?.value;
  };

  @action
  async toggle(setting) {
    await this.save(setting, !setting.value);
  }

  @action
  async updateNumber(setting, event) {
    const val = parseInt(event.target.value, 10);
    if (!isNaN(val)) {
      await this.save(setting, val);
    }
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
      popupAjaxError(error);
    }
  }

  <template>
    <div class="communiteq-powertools-settings admin-config-area__settings">
      {{#each this.settings as |setting|}}
        <div class="admin-config-area__setting-row setting-row
          {{if (this.isDisabled setting) 'disabled'}}">
          <div class="setting-label">
            <label>{{i18n setting.label}}</label>
            {{#if setting.description}}
              <p class="setting-description">{{i18n setting.description}}</p>
            {{/if}}
          </div>
          <div class="setting-control">
            {{#if (eq setting.type "toggle")}}
              <DToggleSwitch
                @state={{setting.value}}
                {{on "click" (fn this.toggle setting)}}
              />
            {{else if (eq setting.type "number")}}
              <input
                type="number"
                value={{setting.value}}
                disabled={{this.isDisabled setting}}
                {{on "change" (fn this.updateNumber setting)}}
                class="number-input"
              />
            {{/if}}
          </div>
        </div>
      {{/each}}
    </div>
  </template>
}
