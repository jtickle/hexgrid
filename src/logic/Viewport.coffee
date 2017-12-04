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
  constructor: (@state) ->
    @vp = @state.viewport

  registerHandlerWith: (register) =>
    register 'viewport.pan', @pan
    register 'viewport.zoom', @zoom
    register 'viewport.resize', @resize
    undefined

  pan: (dx, dy) =>
    [x,y] = @vp.center
    @vp.center = [
      x - dx * @vp.scale,
      y - dy * @vp.scale
    ]
    undefined

  zoom: (pos, ds) =>
    [x,y] = @vp.screenToWorld(pos)
    [cx,cy] = @vp.center
    dx = (x - cx) / @vp.scale
    dy = (y - cy) / @vp.scale
    @vp.adjustScaleBase(ds)
    @vp.center = [
      x - (dx * @vp.scale),
      y - (dy * @vp.scale)
    ]
    undefined

   resize: (width, height) =>
     @vp.width = width
     @vp.canvas.width = width
     @vp.height = height
     @vp.canvas.height = height
     undefined
