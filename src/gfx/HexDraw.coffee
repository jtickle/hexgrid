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

module.exports = class HexDraw
  constructor: (@scene) ->

    @tfm = @scene.tfm
    @hm  = @scene.hm
    @ctx = @scene.ctx

  drawSides: (space, min, max) =>
    [x,y] = @tfm.worldToScreen(@hm.hexCornerToWorld(space.pos, min - 1))
    @ctx.moveTo(x,y)

    for n in [min..max]
      [x,y] = @tfm.worldToScreen(@hm.hexCornerToWorld(space.pos, n))
      @ctx.lineTo(x,y)

  drawAllSides: (space) =>
    @drawSides(space, 0, 5)

  ctxStart: (space) =>
    @ctx.save()
    @ctx.beginPath()
    @drawAllSides(space)

  ctxEnd:() =>
    @ctx.closePath()
    @ctx.restore()

  fill: (space, color) =>
    @ctxStart(space)
    @ctx.fillStyle = color
    @ctx.fill()
    @ctxEnd()

  stroke: (space, color) =>
    @ctxStart(space)
    @ctx.strokeStyle = color
    @ctx.lineWidth = 2
    @ctx.stroke()
    @ctxEnd()

  fillstroke: (space, fcolor, scolor) =>
    @ctxStart(space)
    @ctx.strokeStyle = scolor
    @ctx.fillStyle = fcolor
    @ctx.fill()
    @ctx.stroke()
    @ctxEnd()

  debugSpace: (space, tcolor = '#000') =>
    @ctx.save()
    pos = space.pos

    [x,y] = @tfm.worldToScreen(@hm.hexCenterToWorld(pos))

    @ctx.fillStyle = tcolor
    @ctx.textAlign = "center"
    @ctx.font = "" + Math.floor(14 / @scene.scale) + "px sans-serif"
    @ctx.fillText(space.type, x, y)
    @ctx.font = "" + Math.floor(12 / @scene.scale) + "px sans-serif"
    @ctx.fillText("" + pos[0] + ", " + pos[1], x, y + Math.floor(30 / @scene.scale))

    @ctx.restore()
