import { ajax } from "discourse/lib/ajax";
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
      ajax("/admin/communiteq-powertools/config.json")
        .then((data) => {
          const tabs = [];

          if (data?.acknowledged) {
            tabs.push(
              {
                label: "admin.communiteq_powertools.general_tab",
                route: "adminPlugins.show.communiteq-powertools-general",
              },
              {
                label: "admin.communiteq_powertools.posting_tab",
                route: "adminPlugins.show.communiteq-powertools-posting",
              },
              {
                label: "admin.communiteq_powertools.moderation_tab",
                route: "adminPlugins.show.communiteq-powertools-moderation",
              },
              {
                label: "admin.communiteq_powertools.logging_tab",
                route: "adminPlugins.show.communiteq-powertools-logging",
              }
            );
          }

          tabs.push({
            label: "admin.communiteq_powertools.about_tab",
            route: "adminPlugins.show.communiteq-powertools-about",
          });

          api.addAdminPluginConfigurationNav(PLUGIN_ID, tabs);
        })
        .catch(() => {
          api.addAdminPluginConfigurationNav(PLUGIN_ID, [
            {
              label: "admin.communiteq_powertools.about_tab",
              route: "adminPlugins.show.communiteq-powertools-about",
            },
          ]);
        });
    });
  },
};
