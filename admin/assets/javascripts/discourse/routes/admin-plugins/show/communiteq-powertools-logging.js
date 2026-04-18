import { ajax } from "discourse/lib/ajax";
import { service } from "@ember/service";
import DiscourseRoute from "discourse/routes/discourse";

export default class CommuniteqPowertoolsLoggingRoute extends DiscourseRoute {
  @service router;
  async model() {
    const data = await ajax("/admin/communiteq-powertools/config.json");
    return {
      tab: data.features.find((f) => f.id === "logging") ?? { id: "logging", settings: [] },
      acknowledged: data.acknowledged,
    };
  }

  afterModel(model) {
    if (!model.acknowledged) {
      this.router.replaceWith("adminPlugins.show.communiteq-powertools-about");
    }
  }
}
