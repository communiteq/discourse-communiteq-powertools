import { withPluginApi } from "discourse/lib/plugin-api";

const PLUGIN_ID = "discourse-communiteq-powertools";

export default {
  name: "communiteq-powertools-admin-nav",

  initialize(container) {
    const currentUser = container.lookup("service:current-user");
    if (!currentUser || !currentUser.admin) {
      return;
    }

    withPluginApi((api) => {
      api.setAdminPluginIcon(PLUGIN_ID, "screwdriver-wrench");
      api.addAdminPluginConfigurationNav(PLUGIN_ID, [
        {
          label: "admin.communiteq_powertools.general_tab",
          route: "adminPlugins.show.communiteq-powertools-general",
        },
        {
          label: "admin.communiteq_powertools.posting_tab",
          route: "adminPlugins.show.communiteq-powertools-posting",
        },
      ]);
    });
  },
};
