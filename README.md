grunt-pure-place
================

A Grunt plugin that turns [Pure](http://purecss.io/)'s `.pure____` classes in `src/**/css/*.css` into
`%pure____` [Sass placeholders](http://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#placeholder_selectors_) in `scss/**/_*.scss`.

Does not support responsive classes at this time, due to how Sass handles placeholders
inside of `@media` queries.Uses a custom [Grunt](http://gruntjs.com/) task and some
[Rework](https://github.com/visionmedia/rework).

See [pure-place](https://github.com/jjt/pure-place), a fork of Pure that has had `grunt-pure-place`
run against it with ready-to-use scss placeholders.
