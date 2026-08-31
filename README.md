# discourse-tc-bars :beers: :cocktail:

A theme component that allows you to lay out components[^1] in top and side bars.

* Specify a set of widgets for each route and position.
* Supports homepage, discovery[^2], topic, tag[^3], category[^3], categories[^3], and tags-intersection[^4] routes.
* Bars can use the top, left, centre, right, or alternative right position.
* Each bar can be collapsed or dismissed (refresh the browser to reset a dismissal), and can be minimised by default.
* Handles the official sidebar. If you intend to use a Bars left sidebar, the dropdown mode of the official sidebar is recommended.
* Includes example settings that render large letters. Delete these and replace them with your component names.
* Ships with a `bars-custom-html` component, and supports self-contained components from other theme components and plugins.
* Bars render at Discourse's large viewport breakpoint and above; mobile layouts are unchanged.

Requires Discourse 2026.8.0 or newer.

[Discussion Topic Here](https://meta.discourse.org/t/discourse-bars-a-sidebar-framework/298216)

[^1]: This theme component supports Glimmer components that are self-contained, including fetching their own data, so they can be used on any route.
[^2]: The discovery route refers to the main topic list pages, such as Latest and New.
[^3]: These are also discovery routes, but have distinct names so they can be configured separately.
[^4]: See the [Tags Intersection Plugin](https://meta.discourse.org/t/tag-intersection-navigator/368815?u=merefield)
