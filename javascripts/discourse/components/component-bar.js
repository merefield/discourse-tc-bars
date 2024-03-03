import Component from '@glimmer/component';
import { inject as service } from "@ember/service";
import { action } from '@ember/object';
import { tracked } from "@glimmer/tracking";

export default class ComponentBarComponent extends Component {
  @service router;
  @service site;
  @tracked isVisible = true;

  // constructor() {
  //   super(...arguments);
  //   this.router.on('routeWillChange', this.handleRouteWillChange);
  //   this.router.on('routeDidChange', this.handleRouteDidChange);
  // }

  // willDestroy() {
  //   super.willDestroy();
  //   // Cleanup: Remove event listeners
  //   this.router.off('routeWillChange', this.handleRouteWillChange);
  //   this.router.off('routeDidChange', this.handleRouteDidChange);
  // }

  // @action
  // handleRouteWillChange(transition) {
  //   if (!transition.to || !transition.from) {
  //     return;
  //   }
  //   // Example condition to hide the component
  //   if (transition.to.name !== transition.from.name) {
  //     setTimeout(() => {
  //       this.isVisible = false;
  //     }, 1000); // 1000 milliseconds = 1 second
  //   }
  // }

  // @action
  // handleRouteDidChange() {
  //   this.isVisible = true;
  // }

  get currentBarClasses() {
    switch (this.args.location) {
      case 'top':
        return 'top-bar wrap';
      case 'right-alt':
        return 'right-alt-sidebar';
      default:
        return `${this.args.location}-sidebar`;
    }
  }

  routeCondition(componentRoute) {
    let [baseRoute, subRoute] = this.router.currentRouteName.split('.');
    let isBaseRouteMatch = componentRoute === baseRoute;
    let isSubRouteCategories = subRoute === 'categories';
    let isSubRouteCategory = subRoute === 'category';
    let forbiddenSubRoutes = ['categories', 'category'];

    let routeCondition = (isBaseRouteMatch && !forbiddenSubRoutes.includes(subRoute)) ||
                (componentRoute === 'categories' && isSubRouteCategories) ||
                (componentRoute === 'category' && isSubRouteCategory);
    return routeCondition;
  }

  get currentBarWidth() {
    if (this.barEnabled) {
      switch (this.args.location) {
        case 'top':
          return 'width: 100%';
        case 'right':
          return `width: ${settings.right_sidebar_width}px;`;
        case 'right-alt':
          return `width: ${settings.right_sidebar_width}px;`;
        case 'left':
          return `width: ${settings.left_sidebar_width}px;`;
        default:
          return 'width: 0px';
      }
    } else {
      return 'width: 0px';
    }
  }

  get barEnabled() {
    return !this.site.mobileView && JSON.parse(settings.bar_components).some(component => component.position === this.args.location && this.routeCondition(component.route));
  }

  get inScopeComponents() {
    return JSON.parse(settings.bar_components).filter(component => component.position === this.args.location && this.routeCondition(component.route));
  }
}
