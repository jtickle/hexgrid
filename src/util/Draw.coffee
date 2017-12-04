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
# that code without the copy of the GNU GPL normally requiLayerred by
# section 4, provided you include this license notice and a URL
# through which recipients can access the Corresponding Source.
#

HexMath = require('util/HexMath.coffee')

module.exports = class Draw

  color:
    bgOut:   '#333'
    bgSel:   '#CFC'
    bgWater: '#99C'
    bgRare:  '#C99'
    bgMetal: '#CCC'
    bgNone:  '#CC9'
    lineOut: '#222'
    lineIn:  '#333'
    lineSel: '#0C0'
    error:   '#F00'
    text:    '#333'

  constructor: (viewport, @gridDrawRadius) ->
    @ctx = viewport.ctx
    @view = viewport

  # Useful Transforms

  screenToHex: (screen) =>
    HexMath.hexRound @worldToHex @view.screenToWorld screen

  worldToHex: (pos) =>
    HexMath.worldToHex(@gridDrawRadius, pos)

  hexCenterToWorld: (hex) =>
    HexMath.hexCenterToWorld(@gridDrawRadius, hex)

  hexCornerToWorld: (hex, corner) =>
    HexMath.hexCornerToWorld(@gridDrawRadius, hex, corner)

  # Tile Drawing

  drawSides: (tile, min, max) =>
    [x,y] = @view.worldToScreen(@hexCornerToWorld(tile.pos, min - 1))
    @ctx.moveTo(x,y)

    for n in [min..max]
      [x,y] = @view.worldToScreen(@hexCornerToWorld(tile.pos, n))
      @ctx.lineTo(x,y)

  ctxStart: (tile, s0, sn) =>
    @ctx.save()
    @ctx.beginPath()
    @drawSides(tile, s0, sn)

  ctxEnd:() =>
    @ctx.closePath()
    @ctx.restore()

  fill: (tile, color) =>
    @ctxStart(tile, 0, 5)
    @ctx.fillStyle = color
    @ctx.fill()
    @ctxEnd()

  stroke: (tile, color, s0, sn) =>
    @ctxStart(tile, s0, sn)
    @ctx.strokeXStyle = color
    @ctx.lineWidth = Math.max(0.01, 2 / @view.scale)
    @ctx.stroke()
    @ctxEnd()

  fillstroke: (tile, fcolor, scolor) =>
    @ctxStart(tile, 0, 5)
    @ctx.strokeStyle = scolor
    @ctx.lineWidth = Math.max(0.01, 2 / @view.scale)
    @ctx.fillStyle = fcolor
    @ctx.fill()
    @ctx.stroke()
    @ctxEnd()

  debugTile: (tile, tcolor = '#000') =>
    @ctx.save()
    pos = tile.pos

    [x,y] = @view.worldToScreen(@hexCenterToWorld(pos))
    ox = x - (@gridDrawRadius / @view.scale) / 2
    oy = y - 14 / @view.scale

    @ctx.fillStyle = tcolor
    @ctx.textAlign = "left"
    @ctx.font = "" + Math.floor(12 / @view.scale) + "px sans-serif"
    @ctx.fillText("W: " + tile.resources.water, ox, oy - Math.floor(14 / @view.scale))
    @ctx.fillText("R: " + tile.resources.rare,  ox, oy)
    @ctx.fillText("M: " + tile.resources.metal, ox, oy + Math.floor(14 / @view.scale))
    @ctx.textAlign = "center"
    @ctx.font = "" + Math.floor(10 / @view.scale) + "px sans-serif"
    @ctx.fillText("" + pos[0] + ", " + pos[1], x, y + Math.floor(40 / @view.scale))

    @ctx.restore()
