# frozen_string_literal: true

module CommuniteqPowertools
  PLUGIN_NAME = "discourse-communiteq-powertools"

  class Engine < ::Rails::Engine
    engine_name PLUGIN_NAME
    isolate_namespace CommuniteqPowertools
  end
end

