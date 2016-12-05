This is ruby port of CSS Beautify [cssbeautify](https://github.com/senchalabs/cssbeautify)

# CSS Beautify #

CSS Beautify is a JavaScript implementation of reindenter and reformatter for styles written in [CSS](http://www.w3.org/Style/CSS/).

Given the following style:

```css
menu{color:red} navigation{background-color:#333}
```

CSS Beautify will produce:

```css
menu {
    color: red
}

navigation {
    background-color: #333
}
```

## Install

With Rails:

```ruby
gem 'cssbeautify'
```

Just irb or pry:

```ruby
$ gem install cssbeautify

irb > require 'cssbeautify'
irb > CssBeautify.beautify("menu{color:red} navigation{background-color:#333}")
 => "menu {\n    color: red\n}\nnavigation {\n    background-color: #333\n}"
```

## Using cssbeautify() function ##

Since CSS Beautify is written in pure JavaScript, it can run anywhere that JavaScript can run.

The API is very simple:

```ruby
result = CssBeautify.beautify(style, options);
```

**options** is an optional object to adjust the formatting. Known options so far are:

  *  <code>indent</code> is a string used for the indentation of the declaration (default is 4 spaces)
  *  <code>openbrace</code> defines the placement of open curly brace, either *end-of-line* (default) or *separate-line*.
  *  <code>autosemicolon</code> always inserts a semicolon after the last ruleset (default is *false*)

Example call:

```ruby
beautified = CssBeautify.beautify('menu{opacity:.7}', indent: '  ', openbrace: 'separate-line', autosemicolon: true)
```