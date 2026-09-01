const warnedInvalidSettings = new Set();

export function parseBarComponents(value) {
  if (Array.isArray(value)) {
    return value;
  }

  try {
    const components = JSON.parse(value || "[]");
    return Array.isArray(components) ? components : [];
  } catch (error) {
    if (!warnedInvalidSettings.has(value)) {
      warnedInvalidSettings.add(value);
      // eslint-disable-next-line no-console
      console.warn("Bars! could not parse the bar_components setting", error);
    }

    return [];
  }
}

export function minimizedLocations(value) {
  if (Array.isArray(value)) {
    return value;
  }

  return value ? value.split("|") : [];
}

export function routeMatches(componentRoute, { discovery, routeName }) {
  switch (componentRoute) {
    case "homepage":
      return discovery.custom || routeName === "discovery.custom";
    case "categories":
      return (
        discovery.categoryListPage === "categories" ||
        routeName === "discovery.categories"
      );
    case "category":
      return Boolean(discovery.category);
    case "tag":
      return Boolean(discovery.tag) || routeName?.startsWith("tag.");
    case "tags-intersection":
      return (
        routeName === "tags.intersection" ||
        routeName?.startsWith("tags.intersection.")
      );
    case "topic":
      return routeName === "topic" || routeName?.startsWith("topic.");
    case "discovery":
      return Boolean(
        discovery.onDiscoveryRoute &&
        !discovery.custom &&
        !discovery.categoryListPage &&
        !discovery.category &&
        !discovery.tag
      );
    default:
      return false;
  }
}

export function hasConfiguredBar(components, { position, route }) {
  return parseBarComponents(components).some(
    (component) => component.position === position && component.route === route
  );
}
