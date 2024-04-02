# discourse-tc-bars :beers: :cocktail: 
A Theme Component that allows you to lay out Components ("widgets[^3]") on top and side bars

* Specify a set of "widgets" distinctly for Route and Position.
* Supports setups for each of: discovery[^1], topic, tag[^2], category[^2] OR categories[^2].
* "Bars" can be either: top, left, right OR alternative right location.
* Each bar can be collapsed or dismissed (refresh browser to reset dismiss).  They can be minimised by default.
* Handles the Official Sidebar, but if you intend you use a Bars Left Sidebar, the Dropdown mode of the official Sidebar is recommended.
* It comes with existing example settings that show some big letters, partly as a demo and partly so you can see example settings.  Delete these and replace with your own Component names.
* Ships with one Component: `bars-custom-html` (see pre-filled example settings) - but components from many existing Theme Components & Plugins are compatible.
* Mobile support is not yet implemented.

[Discussion Topic Here](https://meta.discourse.org/t/discourse-bars-a-sidebar-framework/298216)

[^1]: the term 'discovery' (route) refers to the main Topic List pages (e.g. "Latest", "New") that allow you to browse available Topics before clicking and diving into a specific one.
[^2]: technically also a "discovery" route but we're breaking these out to distinct names so you can treat them differently if you so choose.
[^3]: Discourse "widgets" have been deprecated, so this TC only supports Components (in any case Glimmer Components are fast and much more pleasant to develop)
