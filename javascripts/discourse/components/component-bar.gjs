import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { getOwner } from "@ember/owner";
import { service } from "@ember/service";
import bodyClass from "discourse/helpers/body-class";
import DButton from "discourse/ui-kit/d-button";
import dConcatClass from "discourse/ui-kit/helpers/d-concat-class";
import { and, eq, not } from "discourse/truth-helpers";
import { i18n } from "discourse-i18n";
import {
  minimizedLocations,
  parseBarComponents,
  routeMatches,
} from "../lib/bars";

const warnedMissingComponents = new Set();

export default class ComponentBarComponent extends Component {
  @service capabilities;
  @service discovery;
  @service router;

  @tracked isCollapsed = false;
  @tracked isDismissed = false;

  constructor() {
    super(...arguments);
    this.isCollapsed = minimizedLocations(
      settings.sidebars_minimised_by_default
    ).includes(this.args.location);
  }

  get locationClass() {
    return `--${this.args.location}`;
  }

  get bodyClass() {
    return `has-bars-${this.args.location}`;
  }

  get contentId() {
    return `bars-${this.args.location}-content`;
  }

  get label() {
    return i18n(themePrefix(`tc_bars.labels.${this.args.location}`));
  }

  get toggleTitle() {
    const key = this.isCollapsed
      ? "tc_bars.actions.expand"
      : "tc_bars.actions.collapse";

    return themePrefix(key);
  }

  get dismissTitle() {
    return themePrefix("tc_bars.actions.dismiss");
  }

  get toggleIcon() {
    if (this.isCollapsed) {
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

    switch (this.args.location) {
      case "right":
      case "right-alt":
        return "angle-right";
      case "left":
        return "angle-left";
      default:
        return "angle-up";
    }
  }

  get isSticky() {
    return settings.sticky_sidebars && this.args.location !== "centre";
  }

  get isScrollable() {
    return settings.scrolly_sidebars && this.args.location !== "centre";
  }

  get sidebarsCollapsible() {
    return settings.sidebars_collapsible && this.args.location !== "centre";
  }

  get sidebarsDismissible() {
    return settings.sidebars_dismisable && this.args.location !== "centre";
  }

  get showControls() {
    return this.sidebarsCollapsible || this.sidebarsDismissible;
  }

  get inScopeComponents() {
    const owner = getOwner(this);

    return parseBarComponents(settings.bar_components)
      .filter(
        (component) =>
          component.position === this.args.location &&
          routeMatches(component.route, {
            discovery: this.discovery,
            routeName: this.router.currentRouteName,
          })
      )
      .map((component, index) => {
        const componentClass = owner.resolveRegistration(
          `component:${component.component_name}`
        );

        if (!componentClass) {
          this.warnMissingComponent(component.component_name);
          return null;
        }

        return {
          component: componentClass,
          id: `${component.component_name}-${index}`,
          params: Object.fromEntries(
            (component.params || []).map(({ name, value }) => [name, value])
          ),
        };
      })
      .filter(Boolean);
  }

  get barEnabled() {
    return this.capabilities.viewport.lg && this.inScopeComponents.length > 0;
  }

  warnMissingComponent(componentName) {
    if (warnedMissingComponents.has(componentName)) {
      return;
    }

    warnedMissingComponents.add(componentName);
    // eslint-disable-next-line no-console
    console.warn(
      `Bars! issue: component "${componentName}" is not registered despite being specified in Bars configuration. Please check your plugin and theme component installations.`
    );
  }

  @action
  dismiss() {
    this.isDismissed = true;
  }

  @action
  toggle() {
    this.isCollapsed = !this.isCollapsed;
  }

  <template>
    {{#if (and this.barEnabled (not this.isDismissed))}}
      {{bodyClass this.bodyClass}}
      <aside
        class={{dConcatClass
          "bars-bar"
          this.locationClass
          (if this.isCollapsed "is-collapsed")
          (if this.isSticky "--sticky")
          (if this.isScrollable "--scrollable")
          (if (eq @location "top") "wrap")
          (if (eq @location "centre") "wrap")
        }}
        data-position={{@location}}
        aria-label={{this.label}}
        ...attributes
      >
        {{#if this.showControls}}
          <div class="bars-bar__actions">
            {{#if this.sidebarsCollapsible}}
              <DButton
                class="btn-transparent bars-bar__button --toggle"
                @icon={{this.toggleIcon}}
                @title={{this.toggleTitle}}
                @ariaExpanded={{not this.isCollapsed}}
                @ariaControls={{this.contentId}}
                @action={{this.toggle}}
              />
            {{/if}}
            {{#if this.sidebarsDismissible}}
              <DButton
                class="btn-transparent bars-bar__button --dismiss"
                @icon="xmark"
                @title={{this.dismissTitle}}
                @action={{this.dismiss}}
              />
            {{/if}}
          </div>
        {{/if}}
        <div
          id={{this.contentId}}
          class="bars-bar__content"
          hidden={{this.isCollapsed}}
        >
          {{#each this.inScopeComponents key="id" as |inScopeComponent|}}
            <div class="bars-bar__widget component-widget">
              <inScopeComponent.component @params={{inScopeComponent.params}} />
            </div>
          {{/each}}
        </div>
      </aside>
    {{/if}}
  </template>
}
