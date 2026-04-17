export default {
  resource: "admin.adminPlugins.show",
  path: "/plugins",
  map() {
    this.route("communiteq-powertools-general", { path: "general" });
    this.route("communiteq-powertools-posting", { path: "posting" });
  },
};
