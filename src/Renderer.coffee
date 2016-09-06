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

module.exports = class Renderer
  constructor: (@bgColor, @lineColor, @domId, @gridRadius) ->
    @view = document.getElementById(@domId)
    @ctx  = @view.getContext('2d')

    # The position in pixel-worldspace at which the
    # center of the canvas points
    @centerX = 0
    @centerY = 0

    # The base scale setting (Integer from -inf to +inf where
    # 0 = scale of 1:1 and negative gives you a wider perspective)
    @scaleBase = 0

    # The computed scale setting Math.pow(Math.E, scaleBase)
    @scale = 1

    @doResize()
    window.addEventListener("resize", @doResize)

  doResize: () =>
    @width  = document.documentElement.clientWidth
    @height = document.documentElement.clientHeight
    @view.width  = @width
    @view.height = @height
    this

  setScaleBase: (s) =>
    @scaleBase = s
    @scale = Math.pow(Math.E, @scaleBase)
    this

  screenToWorld: (pos) =>
    [x,y] = pos
    [((x - (@width / 2)) * @scale) + @centerX,
     ((y - (@height / 2)) * @scale) + @centerY]

  worldToScreen: (pos) =>
    [x,y] = pos
    [(@width / 2) + ((x - @centerX) / @scale),
     (@height / 2) + ((y - @centerY) / @scale)]

  worldToHex: (pos) =>
    [x,y] = pos
    [(x * Math.sqrt(3) / 3 - y / 3) / @gridRadius,
     y * 2/3 / @gridRadius]

  hexToCube: (h) =>
    x = h[0]
    z = h[1]
    y = -x-z
    [x,y,z]

  cubeToHex: (c) =>
    [q,_,r] = c
    [q,r]

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

  hexRound: (h) =>
    @cubeToHex(@cubeRound(@hexToCube(h)))

  hexDistance: (a, b) =>
    @cubeDistance(@hexToCube(a), @hexToCube(b))

  hexCenterToWorld: (hex) =>
    [hq,hr] = hex
    x = @gridRadius * Math.sqrt(3) * (hq + hr/2)
    y = @gridRadius * 3/2 * hr
    [x,y]
  
  hexCornerToWorld: (hex, corner) =>
    [hq,hr] = hex
    [cx,cy] = @hexCenterToWorld(hex)
    theta = Math.PI / 180 * (60 * corner + 30)

    [cx + @gridRadius * Math.cos(theta),
     cy + @gridRadius * Math.sin(theta)]

  screenToHex: (screen) =>
    @hexRound(@worldToHex(@screenToWorld(screen)))

  createHexLine: (a, b) =>
    n = @hexDistance(a, b)
    (@cubeToHex(@cubeRound(@cubeLerp(@hexToCube(a), @hexToCube(b), (1.0/n) * i))) for i in [0..n])

  blank: () =>
    @ctx.save()
    @ctx.fillStyle = @bgColor
    @ctx.fillRect(0, 0, @width, @height)
    @ctx.restore()

  fillGridSpace: (pos, space) =>
    @ctx.save()
    
    @ctx.beginPath()

    [x,y] = @worldToScreen(@hexCornerToWorld(pos, 5))
    @ctx.moveTo(x,y)

    for n in [0..5]
      [x,y] = @worldToScreen(@hexCornerToWorld(pos, n))
      @ctx.lineTo(x,y)

    @ctx.fillStyle = switch(space.type)
      when "OutOfBounds" then "#666666"
      when "Empty" then "#CCCCCC"
      else "#FF0000"

    @ctx.fill()

    @ctx.restore()

  strokeGridSpace: (pos, space) =>
    @ctx.save()

    for n in [0..2]
      [x0,y0] = @worldToScreen(@hexCornerToWorld(pos, (6-n-1)%6))
      [x1,y1] = @worldToScreen(@hexCornerToWorld(pos, (6-n)%6))

      @ctx.beginPath()
      @ctx.moveTo(x0,y0)
      @ctx.lineTo(x1,y1)
      if space.edges[n]? and space.edges[n].getHighestPriority().type == 'Empty'
        @ctx.strokeStyle = "#00FF00" 
      else 
        @ctx.strokeStyle = "#FFFFFF"
      @ctx.closePath()
      @ctx.stroke()

    @ctx.restore()

  textGridSpace: (pos, space) =>
    @ctx.save()

    [x,y] = @worldToScreen(@hexCenterToWorld(pos))

    @ctx.fillStyle = '#000000'
    @ctx.font = "12px sans-serif"
    @ctx.textAlign = "center"
    @ctx.fillText("" + pos[0] + ", " + pos[1], x, y)

    @ctx.restore()
  
  drawGridSpace: (pos, space) =>
    @fillGridSpace(pos, space)
    @strokeGridSpace(pos, space)
    @textGridSpace(pos, space)

  drawGrid: (grid) =>

    for rowHex in @createHexLine(@screenToHex([0,0]), @screenToHex([0,@height]))
      x0 = 0
      [_,y0] = @worldToScreen(@hexCenterToWorld(rowHex))
      x1 = @width
      y1 = y0
      for hex in @createHexLine(@screenToHex([x0,y0]), @screenToHex([x1,y1]))
        @drawGridSpace(hex, grid.getSpace(hex))
