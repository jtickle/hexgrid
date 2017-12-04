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

module.exports = class Viewport
  center:    [0,0]
  scaleBase:  0
  scale:      1
  height:     0
  width:      0

  constructor: (@domId) ->
    @canvas = document.getElementById(@domId)
    @ctx    = @canvas.getContext('2d')

  setScaleBase: (s) =>
    @scaleBase = s
    @scale = Math.pow(Math.E, @scaleBase)
    this

  adjustScaleBase: (ds) =>
    @setScaleBase(@scaleBase + ds)
    this

  screenToWorld: (pos) =>
    [x,y] = pos
    [cx,cy] = @center
    [
      ((x - (@width/2)) * @scale) + cx,
      ((y - (@height/2)) * @scale) + cy
    ]

  worldToScreen: (pos) =>
    [x,y] = pos
    [cx,cy] = @center
    [
      (@width/2) + ((x - cx) / @scale),
      (@height/2) + ((y - cy) / @scale)
    ]
