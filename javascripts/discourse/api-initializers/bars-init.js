import { apiInitializer } from "discourse/lib/api";
import { hasConfiguredBar } from "../lib/bars";

export default apiInitializer((api) => {
  const capabilities = api.container.lookup("service:capabilities");

  api.registerValueTransformer(
    "topic-navigation-render-timeline",
    ({ value }) => {
      if (
        capabilities.viewport.lg &&
        hasConfiguredBar(settings.bar_components, {
          position: "right",
          route: "topic",
        })
      ) {
        return false;
      }

      return value;
    }
  );
});
