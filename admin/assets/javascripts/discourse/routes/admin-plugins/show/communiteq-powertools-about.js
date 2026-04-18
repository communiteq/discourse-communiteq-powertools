import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class CommuniteqPowertoolsAboutRoute extends DiscourseRoute {
  async model() {
    const data = await ajax("/admin/communiteq-powertools/config.json");
    return { acknowledged: data.acknowledged };
  }
}
