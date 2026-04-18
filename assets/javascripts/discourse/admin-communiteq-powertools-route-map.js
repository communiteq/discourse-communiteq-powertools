export default {
  resource: "admin.adminPlugins.show",
  path: "/plugins",
  map() {
    this.route("communiteq-powertools-about", { path: "about" });
    this.route("communiteq-powertools-general", { path: "general" });
    this.route("communiteq-powertools-posting", { path: "posting" });
    this.route("communiteq-powertools-logging", { path: "logging" });
  },
};
