import CommuniteqPowertoolsSettings from "discourse/plugins/discourse-communiteq-powertools/admin/components/communiteq-powertools-settings";
import DBreadcrumbsItem from "discourse/components/d-breadcrumbs-item";
import { i18n } from "discourse-i18n";

export default <template>
  <DBreadcrumbsItem
    @path="/admin/plugins/discourse-communiteq-powertools/general"
    @label={{i18n "admin.communiteq_powertools.general_tab"}}
  />
  <CommuniteqPowertoolsSettings @tab={{@controller.model}} />
</template>
