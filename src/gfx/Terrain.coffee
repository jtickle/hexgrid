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

module.exports = class Terrain
  constructor: (@scene) ->

    @ctx = @scene.ctx
    @grid = @scene.grid
    @tfm = @scene.tfm

  drawBackground: (ctx) =>
    ctx.save()

    # Blank, dark background
    ctx.fillStyle = @scene.color.bgOut
    ctx.fillRect(0,0,@scene.width,@scene.height)

    ctx.restore()

  drawSides: (ctx, space, min, max) =>
    [x,y] = @scene.tfm.worldToScreen(@hexCornerToWorld(space.pos, min - 1))
    ctx.moveTo(x,y)

    for n in [min..max]
      [x,y] = @scene.tfm.worldToScreen(@hexCornerToWorld(space.pos, max))
      ctx.lineTo(x, y)

  drawAllSides: (ctx, space) =>
    @drawSides(ctx, space, 0, 5)

  fill: (ctx, space) =>
    ctx.save()

    ctx.beginPath()
    @drawAllSides(ctx, space)
    ctx.fillStyle = switch(space.type)
      when "Empty" then @scene.color.bgIn
      else @scene.color.error
    ctx.fill()

    ctx.restore()

  onRender: (layer, rect, context) =>
    r = rect
    g = @grid.getRect(@tfm.screenToHex(r.x          , r.y           ), # Center
                      @tfm.screenToHex(r.x + r.width, r.y           ), # maxQ
                      @tfm.screenToHex(r.x          , r.y + r.height)) # maxR

    @drawBackground(context)

    while !(i = g.next()).done
      space = i.value
      @fill(context, space)

    # TODO: Draw the Terrain Type for the space
