ListView widget for Gigeros
===========================

ListView.lua

Version 0.1 beta

Author: Lukas Gergel, http://pykaso.net

This library is free to use and modify.  Use it for free!

TODO
----
* methods for programatic manipulating with ListView

PARAMS
-----
* width - widget width
* height - widget height
* bgTexture - background texture
* bgColor - background color
* rowSnap - experimental feature
* friction - number lower then 1, used for slow the list down 
* data - array of pre renderend rows (see examples)

USAGE
-----

Example
```lua
myList = ListView.new({
   width=280,
   height=390,
   bgTexture = Texture.new("texture.png"),
   rowSnap = true, experimental feature
   friction = 0.92
   data=data
})
myList:setPosition(x, y)
```

Minimal example
```lua
myList = ListView.new({
   width=280,
   height=390,
   data=data
})
```
