import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import DBreadcrumbsItem from "discourse/components/d-breadcrumbs-item";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";

class CommuniteqPowertoolsAbout extends Component {
  @tracked acknowledged = this.args.model?.acknowledged ?? false;
  @tracked saving = false;

  @action
  async acknowledge() {
    this.saving = true;
    try {
      await ajax("/admin/communiteq-powertools/acknowledge", { type: "POST" });
      this.acknowledged = true;
      window.location.assign(
        "/admin/plugins/discourse-communiteq-powertools/general"
      );
    } catch (e) {
      popupAjaxError(e);
    } finally {
      this.saving = false;
    }
  }

  <template>
    <DBreadcrumbsItem
      @path="/admin/plugins/discourse-communiteq-powertools/about"
      @label={{i18n "admin.communiteq_powertools.about_tab"}}
    />

    <div class="cpt-about">
      <img
        class="cpt-about__banner"
        src="/plugins/discourse-communiteq-powertools/images/powertools-banner.png"
        alt="Communiteq Powertools"
      />

      {{#unless this.acknowledged}}
        <div class="cpt-about__disclaimer">
          <p>{{i18n "admin.communiteq_powertools.about_disclaimer"}}</p>
          <button
            class="btn btn-primary cpt-about__understand-btn"
            disabled={{this.saving}}
            {{on "click" this.acknowledge}}
          >
            {{i18n "admin.communiteq_powertools.about_i_understand"}}
          </button>
        </div>
      {{/unless}}
    </div>
  </template>
}

<template><CommuniteqPowertoolsAbout @model={{@controller.model}} /></template>
