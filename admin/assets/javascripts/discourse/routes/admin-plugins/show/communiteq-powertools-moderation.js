import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class CommuniteqPowertoolsModerationRoute extends DiscourseRoute {
  @service router;

  async model() {
    const data = await ajax("/admin/communiteq-powertools/config.json");
    return {
      tab: data.features.find((f) => f.id === "moderation") ?? {
        id: "moderation",
        settings: [],
      },
      acknowledged: data.acknowledged,
    };
  }

  afterModel(model) {
    if (!model.acknowledged) {
      this.router.replaceWith("adminPlugins.show.communiteq-powertools-about");
    }
  }
}
