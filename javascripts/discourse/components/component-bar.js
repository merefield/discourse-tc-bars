import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { service } from "@ember/service";
import { htmlSafe } from "@ember/template";
import { getOwner } from "@ember/application";

export default class ComponentBarComponent extends Component {
  @service router;
  @service site;

  @tracked toggleState = "expanded";
  @tracked visability = "show";

  constructor() {
    super(...arguments);
    this.router.on("routeDidChange", this.setupWrapper);
    if (settings.sidebars_minimised_by_default.includes(this.args.location)) {
      this.toggleState = "collapsed";
    }
  }

  willDestroy() {
    super.willDestroy();
    this.router.off("routeDidChange", this.setupWrapper);
  }

  get currentBarClasses() {
    switch (this.args.location) {
      case "top":
        return "top-bar wrap";
      case "centre":
        return "centre wrap";
      case "right-alt":
        return "right-alt-sidebar";
      default:
        return `${this.args.location}-sidebar`;
    }
  }

  get currentBarWidth() {
    if (this.barEnabled && this.toggleState === "expanded") {
      switch (this.args.location) {
        case "top":
          return htmlSafe("width: 100%;");
        case "centre":
          return htmlSafe("");
        case "right":
          return htmlSafe(
            `width: ${parseInt(settings.right_sidebar_width, 10)}px;`
          );
        case "right-alt":
          return htmlSafe(
            `width: ${parseInt(settings.right_sidebar_width, 10)}px;`
          );
        case "left":
          return htmlSafe(
            `width: ${parseInt(settings.left_sidebar_width, 10)}px;`
          );
        default:
          return htmlSafe("display: none;");
      }
    } else if (this.barEnabled && this.toggleState === "collapsed") {
      return htmlSafe("width: auto;");
    } else {
      return htmlSafe("display: none;");
    }
  }

  get getSticky() {
    if (
      this.barEnabled &&
      settings.sticky_sidebars &&
      this.args.location !== "centre"
    ) {
      return htmlSafe(" position: sticky; position: -webkit-sticky;");
    } else {
      return htmlSafe("");
    }
  }

  get getScrolly() {
    if (
      this.barEnabled &&
      settings.scrolly_sidebars &&
      this.args.location !== "centre"
    ) {
      return htmlSafe("  overflow-y: scroll;");
    } else {
      return htmlSafe("");
    }
  }

  routeCondition(componentRoute) {
    let [baseRoute, subRoute] = this.router.currentRouteName.split(".");
    let isBaseRouteMatch = componentRoute === baseRoute;
    let isSubRouteCategories = subRoute === "categories";
    let isSubRouteCategory = subRoute === "category";
    let isCustomHomePage = subRoute === "custom";
    let isTagsIntersection =
      baseRoute === "tags" && subRoute === "intersection";
    let forbiddenSubRoutes = ["categories", "category", "custom"];

    let routeCondition =
      (isBaseRouteMatch && !forbiddenSubRoutes.includes(subRoute)) ||
      (componentRoute === "categories" && isSubRouteCategories) ||
      (componentRoute === "category" && isSubRouteCategory) ||
      (componentRoute === "tags-intersection" && isTagsIntersection) ||
      (componentRoute === "homepage" && isCustomHomePage);
    return routeCondition;
  }

  get barEnabled() {
    return (
      !this.site.mobileView &&
      JSON.parse(settings.bar_components).some(
        (component) =>
          component.position === this.args.location &&
          this.routeCondition(component.route)
      )
    );
  }

  get inScopeComponents() {
    const barComponents = JSON.parse(settings.bar_components);
    const owner = getOwner(this);

    barComponents.forEach(({ component_name }) => {
      if (!owner.hasRegistration(`component:${component_name}`)) {
        // eslint-disable-next-line no-console
        console.warn(
          `Bars! issue: component "${component_name}" is not registered despite being specified in Bars configuration. Please check your Plugin and Theme Component installations.`
        );
      }
    });

    const components = barComponents.filter(
      (component) =>
        component.position === this.args.location &&
        this.routeCondition(component.route) &&
        owner.hasRegistration(`component:${component.component_name}`)
    );

    components.forEach((component) => {
      component.parsedParams = {};
      if (component.params) {
        component.params.forEach((p) => {
          component.parsedParams[p.name] = p.value;
        });
      }
    });
    return components;
  }

  get toggleIcon() {
    switch (this.toggleState) {
      case "expanded":
        switch (this.args.location) {
          case "right":
          case "right-alt":
            return "angle-right";
          case "left":
            return "angle-left";
          default:
            return "angle-up";
        }

      default:
        switch (this.args.location) {
          case "right":
          case "right-alt":
            return "angle-left";
          case "left":
            return "angle-right";
          default:
            return "angle-down";
        }
    }
  }

  get sidebarsCollapsible() {
    return settings.sidebars_collapsible && this.args.location !== "centre";
  }

  get sidebarsDismisable() {
    return settings.sidebars_dismisable && this.args.location !== "centre";
  }

  @action
  dismiss() {
    if (this.visability === "show") {
      this.visability = "hide";
    }
  }

  @action
  toggleTheState() {
    if (this.toggleState === "expanded") {
      this.toggleState = "collapsed";
    } else {
      this.toggleState = "expanded";
    }
  }

  @action
  setupWrapper() {
    if (this.barEnabled) {
      switch (this.args.location) {
        case "right":
          document
            .getElementById("main-outlet-wrapper")
            .classList.add("has-sidebar");
          break;
        case "left":
          document
            .getElementById("main-outlet-wrapper")
            .classList.add("has-sidebar");
      }
    }
  }
}
