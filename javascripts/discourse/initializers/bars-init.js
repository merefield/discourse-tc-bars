import { withPluginApi } from "discourse/lib/plugin-api";
// import SwipeEvents from "discourse/lib/swipe-events";
import { headerOffset } from "discourse/lib/offset-calculator";

const PLUGIN_ID = "discourse-tc-bars";
const MIN_HEIGHT_TIMELINE = 325;

export default {
  name: "bars!",
  initialize(container) {
    withPluginApi("0.8.40", (api) => {
      api.modifyClass("component:topic-navigation", {
        pluginId: PLUGIN_ID,

        _performCheckSize() {
          if (!this.element || this.isDestroying || this.isDestroyed) {
            return;
          }

          let topicSidebar = JSON.parse(settings.bar_components).some(
            (component) =>
              component.position === "right" && component.route === "topic"
          );

          this.info.set("renderTimeline", false);

          if (this.info.topicProgressExpanded && !topicSidebar) {
            this.info.set("renderTimeline", true);
          } else if (this.site.mobileView) {
            this.info.set("renderTimeline", false);
          } else if (!topicSidebar) {
            const composerHeight =
              document.querySelector("#reply-control")?.offsetHeight || 0;
            const verticalSpace =
              window.innerHeight - composerHeight - headerOffset();

            this.info.set(
              "renderTimeline",
              this.mediaQuery.matches && verticalSpace > MIN_HEIGHT_TIMELINE
            );
          }
        },
      });
    });
  },
};
