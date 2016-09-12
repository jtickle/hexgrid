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

module.exports = class HexGrid
  constructor: (@scene) ->
    @ctx = @scene.ctx
    @tfm = @scene.tfm

# Coordinate System Transforms

  screenToHex: (screen) =>
    @hexRound(@worldToHex(@tfm.screenToWorld(screen)))
  
  worldToHex: (pos) =>
    [x,y] = pos
    [x * 2/3 / @scene.gridRadius,
     (-x / 3 + Math.sqrt(3)/3 * y) / @scene.gridRadius]

  hexCenterToWorld: (hex) =>
    [hq,hr] = hex
    x = @scene.gridRadius * 3/2 * hq
    y = @scene.gridRadius * Math.sqrt(3) * (hr + hq/2)
    [x,y]
  
  hexCornerToWorld: (hex, corner) =>
    [hq,hr] = hex
    [cx,cy] = @hexCenterToWorld(hex)
    theta = Math.PI / 180 * (60 * ((6 - corner) % 6))

    [cx + @scene.gridRadius * Math.cos(theta),
     cy + @scene.gridRadius * Math.sin(theta)]

  hexToCube: (h) =>
    x = h[0]
    z = h[1]
    y = -x-z
    [x,y,z]

  cubeToHex: (c) =>
    [q,_,r] = c
    [q,r]

# Cube Math

  lerp: (a, b, t) =>
    a + (b - a) * t

  cubeLerp: (a, b, t) =>
    [aX,aY,aZ] = a
    [bX,bY,bZ] = b
    [@lerp(aX, bX, t),
     @lerp(aY, bY, t),
     @lerp(aZ, bZ, t)]

  cubeDistance: (a, b) =>
    [aX,aY,aZ] = a
    [bX,bY,bZ] = b
    (Math.abs(aX - bX) + Math.abs(aY - bY) + Math.abs(aZ - bZ)) / 2

  cubeRound: (c) =>
    [x,y,z] = c
    rx = Math.round(x)
    ry = Math.round(y)
    rz = Math.round(z)

    dx = Math.abs(rx - x)
    dy = Math.abs(ry - y)
    dz = Math.abs(rz - z)

    if dx > dy and dx > dz
      rx = -ry-rz
    else if dy > dz
      ry = -rx-rz
    else
      rz = -rx-ry

    [rx, ry, rz]

# Hex Math

  hexRound: (h) =>
    @cubeToHex(@cubeRound(@hexToCube(h)))

  hexDistance: (a, b) =>
    @cubeDistance(@hexToCube(a), @hexToCube(b))

  createHexLine: (a, b) =>
    n = @hexDistance(a, b)
    (@cubeToHex(@cubeRound(@cubeLerp(@hexToCube(a), @hexToCube(b), (1.0/n) * i))) for i in [0..n])

# Tile Drawing

  drawSides: (tile, min, max) =>
    [x,y] = @tfm.worldToScreen(@hexCornerToWorld(tile.pos, min - 1))
    @ctx.moveTo(x,y)

    for n in [min..max]
      [x,y] = @tfm.worldToScreen(@hexCornerToWorld(tile.pos, n))
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
    @ctx.strokeStyle = color
    @ctx.lineWidth = 2
    @ctx.stroke()
    @ctxEnd()

  fillstroke: (tile, fcolor, scolor) =>
    @ctxStart(tile, 0, 5)
    @ctx.strokeStyle = scolor
    @ctx.fillStyle = fcolor
    @ctx.fill()
    @ctx.stroke()
    @ctxEnd()

  debugTile: (tile, tcolor = '#000') =>
    @ctx.save()
    pos = tile.pos

    [x,y] = @tfm.worldToScreen(@hexCenterToWorld(pos))
    ox = x - (@scene.gridRadius / @scene.scale) / 2
    oy = y - 14 / @scene.scale

    @ctx.fillStyle = tcolor
    @ctx.textAlign = "left"
    @ctx.font = "" + Math.floor(12 / @scene.scale) + "px sans-serif"
    @ctx.fillText("W: " + tile.resources.water, ox, oy - Math.floor(14 / @scene.scale))
    @ctx.fillText("R: " + tile.resources.rare,  ox, oy)
    @ctx.fillText("M: " + tile.resources.metal, ox, oy + Math.floor(14 / @scene.scale))
    @ctx.textAlign = "center"
    @ctx.font = "" + Math.floor(10 / @scene.scale) + "px sans-serif"
    @ctx.fillText("" + pos[0] + ", " + pos[1], x, y + Math.floor(40 / @scene.scale))

    @ctx.restore()
