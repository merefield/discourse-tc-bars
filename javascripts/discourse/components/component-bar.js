import Component from '@glimmer/component';
import { inject as service } from "@ember/service";
import { htmlSafe } from "@ember/template";

export default class ComponentBarComponent extends Component {
  @service router;
  @service site;

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

  get currentBarWidth() {
    if (this.barEnabled) {
      switch (this.args.location) {
        case 'top':
          return htmlSafe('width: 100%');
        case 'right':
          return htmlSafe(`width: ${parseInt(settings.right_sidebar_width)}px;`);
        case 'right-alt':
          return htmlSafe(`width: ${parseInt(settings.right_sidebar_width)}px;`);
        case 'left':
          return htmlSafe(`width: ${parseInt(settings.left_sidebar_width)}px;`);
        default:
          return htmlSafe('width: 0px');
      }
    } else {
      return htmlSafe('width: 0px');
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

  get barEnabled() {
    return !this.site.mobileView && JSON.parse(settings.bar_components).some(component => component.position === this.args.location && this.routeCondition(component.route));
  }

  get inScopeComponents() {
    return JSON.parse(settings.bar_components).filter(component => component.position === this.args.location && this.routeCondition(component.route));
  }
}
