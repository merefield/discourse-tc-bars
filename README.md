# discourse-tc-bars :beers: :cocktail: 
A Theme Component that allows you to lay out Components ("widgets*") on top and side bars

* Specify a set of "widgets" distinctly for Route and Position.
* Supports setups for each of: discovery, topic, tag, category OR categories.
* "Bars" can be either: top, left, right OR alternative right location.
* Components must source their own data (they can't use plugin outlet pass-through models unfortunately due to the specific plugin outlets required to be used to lay things out in this way)
* Mobile support is not yet implemented.

<sup>* Discourse "widgets" have been deprecated, so this TC only supports Components (in any case Glimmer Components are fast and much more pleasant to develop)