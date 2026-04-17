import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class CommuniteqPowertoolsGeneralRoute extends DiscourseRoute {
  model() {
    return ajax("/admin/communiteq-powertools/config.json").then(
      (data) =>
        data.features.find((f) => f.id === "general") ?? {
          id: "general",
          settings: [],
        }
    );
  }
}
