# frozen_string_literal: true

require "rails_helper"
require_relative "../../../app/controllers/admin/communiteq_powertools_controller"

describe Admin::CommuniteqPowertoolsController do
  fab!(:admin) { Fabricate(:admin) }

  before do
    controller.stubs(:current_user).returns(admin)
    controller.stubs(:ensure_admin).returns(true)
    if !SiteSetting.respond_to?(:communiteq_powertools_enabled)
      SiteSetting.singleton_class.send(:define_method, :communiteq_powertools_enabled) { true }
    end
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get "admin/communiteq-powertools/config" => "admin/communiteq_powertools#index"
      post "admin/communiteq-powertools/config" => "admin/communiteq_powertools#update"
      post "admin/communiteq-powertools/acknowledge" => "admin/communiteq_powertools#acknowledge"
    end
  end

  describe "#index" do
    it "returns features and acknowledgement state" do
      controller.stubs(:get_features_config).returns([])
      get :index, format: :json

      expect(response.status).to eq(200)
      json = response.parsed_body
      expect(json["features"]).to eq([])
      expect(json).to have_key("enabled")
      expect(json).to have_key("acknowledged")
    end
  end

  describe "#update" do
    it "updates a setting and logs site setting change" do
      expect(SiteSetting.enable_badge_sql).to eq(false)

      expect do
        post :update,
             params: {
               feature: "general",
               setting_name: "enable_badge_sql",
               value: true,
             },
             format: :json
      end.to change { UserHistory.where(action: UserHistory.actions[:change_site_setting]).count }.by(1)

      expect(response.status).to eq(200)
      expect(response.parsed_body["success"]).to eq(true)
      expect(SiteSetting.enable_badge_sql).to eq(true)
    end

    it "updates allow_embedding_site_in_an_iframe and logs site setting change" do
      current_value = SiteSetting.allow_embedding_site_in_an_iframe
      new_value = !current_value

      expect do
        post :update,
             params: {
               feature: "general",
               setting_name: "allow_embedding_site_in_an_iframe",
               value: new_value,
             },
             format: :json
      end.to change { UserHistory.where(action: UserHistory.actions[:change_site_setting]).count }.by(1)

      expect(response.status).to eq(200)
      expect(response.parsed_body["success"]).to eq(true)
      expect(SiteSetting.allow_embedding_site_in_an_iframe).to eq(new_value)
    end

    it "returns 422 for invalid values" do
      post :update,
           params: {
             feature: "general",
             setting_name: "max_category_nesting",
             value: 5,
           },
           format: :json

      expect(response.status).to eq(422)
      expect(response.parsed_body["error"]).to eq("Invalid setting value")
    end

    it "returns 400 for unknown setting" do
      post :update,
           params: {
             feature: "posting",
             setting_name: "does_not_exist",
             value: true,
           },
           format: :json

      expect(response.status).to eq(400)
      expect(response.parsed_body["error"]).to eq("Invalid setting")
    end
  end

  describe "#acknowledge" do
    it "stores acknowledgement on current user" do
      expect(admin.custom_fields["communiteq_powertools_acknowledged"]).not_to eq("true")

      post :acknowledge, format: :json

      expect(response.status).to eq(200)
      expect(response.parsed_body["success"]).to eq(true)
      expect(admin.reload.custom_fields["communiteq_powertools_acknowledged"]).to eq("true")
    end
  end
end
