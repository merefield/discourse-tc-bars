import { module, test } from "qunit";
import {
  hasConfiguredBar,
  minimizedLocations,
  parseBarComponents,
  routeMatches,
} from "../../../discourse/lib/bars";

function discovery(overrides = {}) {
  return {
    category: undefined,
    categoryListPage: undefined,
    custom: false,
    onDiscoveryRoute: true,
    tag: undefined,
    ...overrides,
  };
}

module("Unit | Lib | bars", function () {
  test("parseBarComponents accepts serialized and hydrated settings", function (assert) {
    const components = [{ component_name: "example" }];

    assert.deepEqual(
      parseBarComponents(JSON.stringify(components)),
      components,
      "parses the legacy JSON setting"
    );
    assert.strictEqual(
      parseBarComponents(components),
      components,
      "accepts a hydrated objects setting"
    );
  });

  test("minimizedLocations matches complete location names", function (assert) {
    const locations = minimizedLocations("left|right-alt");

    assert.true(locations.includes("left"), "matches a configured location");
    assert.true(
      locations.includes("right-alt"),
      "matches a configured hyphenated location"
    );
    assert.false(
      locations.includes("right"),
      "does not partially match right-alt"
    );
  });

  test("routeMatches recognizes semantic discovery routes", function (assert) {
    assert.true(
      routeMatches("homepage", {
        discovery: discovery({ custom: true }),
        routeName: "discovery.custom",
      }),
      "matches the custom homepage"
    );
    assert.true(
      routeMatches("categories", {
        discovery: discovery({ categoryListPage: "categories" }),
        routeName: "discovery.categories",
      }),
      "matches the categories page"
    );
    assert.true(
      routeMatches("category", {
        discovery: discovery({ category: { id: 1 } }),
        routeName: "discovery.latestCategory",
      }),
      "matches filtered category routes"
    );
    assert.true(
      routeMatches("tag", {
        discovery: discovery({ tag: { name: "support" } }),
        routeName: "tags.showCategory",
      }),
      "matches tag routes filtered by category"
    );
  });

  test("routeMatches keeps generic discovery separate", function (assert) {
    assert.true(
      routeMatches("discovery", {
        discovery: discovery(),
        routeName: "discovery.latest",
      }),
      "matches a generic topic list"
    );
    assert.false(
      routeMatches("discovery", {
        discovery: discovery({ category: { id: 1 } }),
        routeName: "discovery.latestCategory",
      }),
      "excludes category topic lists"
    );
    assert.false(
      routeMatches("discovery", {
        discovery: discovery({ tag: { name: "support" } }),
        routeName: "tag.show",
      }),
      "excludes tag topic lists"
    );
  });

  test("routeMatches recognizes topic and tag intersection routes", function (assert) {
    assert.true(
      routeMatches("topic", {
        discovery: discovery({ onDiscoveryRoute: false }),
        routeName: "topic.fromParams",
      }),
      "matches a topic child route"
    );
    assert.true(
      routeMatches("tags-intersection", {
        discovery: discovery({ onDiscoveryRoute: false }),
        routeName: "tags.intersection",
      }),
      "matches the tag intersection plugin route"
    );
  });

  test("hasConfiguredBar matches both position and route", function (assert) {
    const components = [
      { component_name: "example", position: "right", route: "topic" },
    ];

    assert.true(
      hasConfiguredBar(components, { position: "right", route: "topic" }),
      "matches the configured bar"
    );
    assert.false(
      hasConfiguredBar(components, { position: "right-alt", route: "topic" }),
      "rejects a different position"
    );
  });
});
