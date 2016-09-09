# 
# HexGrid - Copyright (C) 2016  Jeffrey W. Tickle
# 
# The CoffeeScript code in this page is free software: you can
# redistribute it and/or modify it under the terms of the GNU
# General Public License (GNU GPL) as published by the Free Software
# Foundation, either version 3 of the License, or (at your option)
# any later version.  The code is distributed WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU GPL for more details.
# 
# As additional permission under GNU GPL version 3 section 7, you
# may distribute non-source (e.g., minimized or compacted) forms of
# that code without the copy of the GNU GPL normally required by
# section 4, provided you include this license notice and a URL
# through which recipients can access the Corresponding Source.
# 

module.exports = class Transforms
  constructor: (@scene) ->
    @hm = @scene.hm

  screenToWorld: (pos) =>
    [x,y] = pos
    [cx,cy] = @scene.center
    [((x - (@scene.width / 2)) * @scene.scale) + cx,
     ((y - (@scene.height / 2)) * @scene.scale) + cy]

  worldToScreen: (pos) =>
    [x,y] = pos
    [cx,cy] = @scene.center
    [(@scene.width / 2) + ((x - cx) / @scene.scale),
     (@scene.height / 2) + ((y - cy) / @scene.scale)]

  screenToHex: (screen) =>
    @hm.hexRound(@hm.worldToHex(@screenToWorld(screen)))
