import { click, find, render } from "@ember/test-helpers";
import { module, test } from "qunit";
import { setupRenderingTest } from "discourse/tests/helpers/component-test";
import ComponentBar from "../../../discourse/components/component-bar";

const TestWidget = <template>
  <span class="bars-test-widget">
    <span class="bars-test-widget__modern">{{@content}}</span>
    <span class="bars-test-widget__legacy">{{@params.content}}</span>
  </span>
</template>;

function configureWidget(position) {
  settings.bar_components = JSON.stringify([
    {
      component_name: "bars-test-widget",
      position,
      route: "discovery",
      params: [{ name: "content", value: "Widget content" }],
    },
  ]);
}

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

  test("releases right sidebar width when collapsed", async function (assert) {
    configureWidget("right");

    await render(
      <template>
        <div id="main-outlet-wrapper" style="width: 1000px;">
          <main id="main-outlet"></main>
          <ComponentBar @location="right" />
        </div>
      </template>
    );

    const expandedContentWidth =
      find("#main-outlet").getBoundingClientRect().width;
    const expandedBarWidth = find(".bars-bar").getBoundingClientRect().width;

    await click(".bars-bar__button.--toggle");

    const contentRect = find("#main-outlet").getBoundingClientRect();
    const barRect = find(".bars-bar").getBoundingClientRect();

    assert.true(
      contentRect.width > expandedContentWidth,
      "returns the collapsed sidebar width to the main content"
    );
    assert.true(
      barRect.width < expandedBarWidth,
      "shrinks the sidebar to its controls"
    );
    assert.true(
      barRect.left >= contentRect.right,
      "keeps the collapsed controls on the right of the main content"
    );
    assert.strictEqual(
      getComputedStyle(find(".bars-bar__actions")).flexDirection,
      "column",
      "stacks the remaining controls vertically"
    );
  });

  test("releases right-alt sidebar width when collapsed", async function (assert) {
    configureWidget("right-alt");

    await render(
      <template>
        <div class="list-container">
          <div class="row full-width" style="width: 1000px;">
            <div id="list-area"></div>
            <ComponentBar @location="right-alt" />
          </div>
        </div>
      </template>
    );

    const expandedContentWidth =
      find("#list-area").getBoundingClientRect().width;
    const expandedBarWidth = find(".bars-bar").getBoundingClientRect().width;

    await click(".bars-bar__button.--toggle");

    const contentRect = find("#list-area").getBoundingClientRect();
    const barRect = find(".bars-bar").getBoundingClientRect();

    assert.true(
      contentRect.width > expandedContentWidth,
      "returns the collapsed alternative sidebar width to the topic list"
    );
    assert.true(
      barRect.width < expandedBarWidth,
      "shrinks the alternative sidebar to its controls"
    );
    assert.true(
      barRect.left >= contentRect.right,
      "keeps the collapsed controls on the right of the topic list"
    );
    assert.strictEqual(
      getComputedStyle(find(".bars-bar__actions")).flexDirection,
      "column",
      "stacks the remaining controls vertically"
    );
  });

  test("releases left sidebar width when collapsed", async function (assert) {
    configureWidget("left");

    await render(
      <template>
        <div id="main-outlet-wrapper" style="width: 1000px;">
          <ComponentBar @location="left" />
          <main id="main-outlet"></main>
        </div>
      </template>
    );

    const expandedContentWidth =
      find("#main-outlet").getBoundingClientRect().width;
    const expandedBarWidth = find(".bars-bar").getBoundingClientRect().width;

    await click(".bars-bar__button.--toggle");

    const contentRect = find("#main-outlet").getBoundingClientRect();
    const barRect = find(".bars-bar").getBoundingClientRect();

    assert.true(
      contentRect.width > expandedContentWidth,
      "returns the collapsed sidebar width to the main content"
    );
    assert.true(
      barRect.width < expandedBarWidth,
      "shrinks the sidebar to its controls"
    );
    assert.true(
      barRect.right <= contentRect.left,
      "keeps the collapsed controls on the left of the main content"
    );
    assert.strictEqual(
      getComputedStyle(find(".bars-bar__actions")).flexDirection,
      "column",
      "stacks the remaining controls vertically"
    );
  });

  test("collapses the top bar upward", async function (assert) {
    configureWidget("top");

    await render(<template><ComponentBar @location="top" /></template>);

    const expandedRect = find(".bars-bar").getBoundingClientRect();

    await click(".bars-bar__button.--toggle");

    const collapsedRect = find(".bars-bar").getBoundingClientRect();

    assert.true(
      collapsedRect.height < expandedRect.height,
      "removes the content height from the collapsed top bar"
    );
    assert.true(
      collapsedRect.bottom < expandedRect.bottom,
      "moves the bottom edge upward"
    );
    assert.strictEqual(
      getComputedStyle(find(".bars-bar__actions")).flexDirection,
      "row",
      "keeps top bar controls horizontal"
    );
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
