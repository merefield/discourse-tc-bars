import { click, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import ComponentBar from "../../../discourse/components/component-bar";

const TestWidget = <template>
  <span class="bars-test-widget">
    <span class="bars-test-widget__modern">{{@content}}</span>
    <span class="bars-test-widget__legacy">{{@params.content}}</span>
  </span>
</template>;

module("Integration | Component | ComponentBar", function (hooks) {
  setupRenderingTest(hooks, { stubRouter: true });

  hooks.beforeEach(function () {
    this.originalBarComponents = settings.bar_components;
    this.originalMinimized = settings.sidebars_minimised_by_default;
    settings.bar_components = JSON.stringify([
      {
        component_name: "bars-test-widget",
        position: "left",
        route: "discovery",
        params: [{ name: "content", value: "Widget content" }],
      },
    ]);
    settings.sidebars_minimised_by_default = "";

    this.owner.register("component:bars-test-widget", TestWidget);
    this.owner.unregister("service:capabilities");
    this.owner.register(
      "service:capabilities",
      { viewport: { lg: true } },
      { instantiate: false }
    );

    const router = this.owner.lookup("service:router");
    router.currentRouteName = "discovery.latest";
    router.currentRoute = { attributes: {} };
  });

  hooks.afterEach(function () {
    settings.bar_components = this.originalBarComponents;
    settings.sidebars_minimised_by_default = this.originalMinimized;
  });

  test("renders the configured widget with accessible controls", async function (assert) {
    await render(<template><ComponentBar @location="left" /></template>);

    assert
      .dom('.bars-bar[data-position="left"]')
      .hasAttribute("aria-label", "Left sidebar", "labels the bar landmark");
    assert
      .dom(".bars-bar__button.--toggle")
      .hasAttribute("title", "Collapse bar", "labels the collapse action")
      .hasAttribute("aria-expanded", "true", "exposes the expanded state")
      .hasAttribute(
        "aria-controls",
        "bars-left-content",
        "identifies the controlled content"
      );
    assert
      .dom(".bars-bar__button.--dismiss")
      .hasAttribute("title", "Dismiss bar", "labels the dismiss action");
  });

  test("passes configured parameters as modern and legacy arguments", async function (assert) {
    await render(<template><ComponentBar @location="left" /></template>);

    assert
      .dom(".bars-test-widget__modern")
      .hasText("Widget content", "passes the parameter as a named argument");
    assert
      .dom(".bars-test-widget__legacy")
      .hasText("Widget content", "preserves the legacy params argument");
  });

  test("collapses and expands the bar content", async function (assert) {
    await render(<template><ComponentBar @location="left" /></template>);

    await click(".bars-bar__button.--toggle");

    assert
      .dom("#bars-left-content")
      .hasAttribute("hidden", "", "hides the collapsed content");
    assert
      .dom(".bars-bar__button.--toggle")
      .hasAttribute("aria-expanded", "false", "exposes the collapsed state");

    await click(".bars-bar__button.--toggle");

    assert
      .dom("#bars-left-content")
      .doesNotHaveAttribute("hidden", "shows the expanded content");
  });

  test("dismisses the bar", async function (assert) {
    await render(<template><ComponentBar @location="left" /></template>);

    await click(".bars-bar__button.--dismiss");

    assert.dom(".bars-bar").doesNotExist("removes the dismissed bar");
    assert
      .dom(document.body)
      .doesNotHaveClass("has-bars-left", "removes the bar layout state");
  });
});
