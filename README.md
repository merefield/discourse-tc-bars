# discourse-tc-bars
A Theme Component that allows you to lay out Components ("widgets") on top and side bars

* Discourse "widgets" have been deprecated, so this TC only supports Components (in any case Glimmer Components are fast and much more pleasant to develop)
* Components must source their own data (they can't use plugin outlet pass-through models unfortunately due to the specific plugin outlets required to be used to lay things out in this way)
* Mobile support is not yet implemented.
