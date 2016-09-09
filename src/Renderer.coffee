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
  center:    [0,0]
  scaleBase:  0
  scale:      1
  width:      0
  height:     0
  dt:         0
  color:
    bgOut:   '#333'
    bgIn:    '#CCC'
    lineOut: '#222'
    lineIn:  '#333'
    lineSel: '#0C0'
    error:   '#F00'
    text:    '#333'

  constructor: (@domId, @gridRadius) ->
    @view  = document.getElementById(@domId)
    @ctx   = @view.getContext('2d')

    @notifyResize()
    window.addEventListener("resize", @notifyResize)

  setScaleBase: (s) =>
    @scaleBase = s
    @scale = Math.pow(Math.E, @scaleBase)
    this

  adjustScaleBase: (ds) =>
    @setScaleBase(@scaleBase + ds)
    this

  setCenter: (pos) =>
    @center = pos

  notifyResize: () =>
    @width  = document.documentElement.clientWidth
    @height = document.documentElement.clientHeight
    @view.width   = @width
    @view.height  = @height
    this

  blank: () =>
    #@ctx.save()
    #@ctx.fillStyle = @bgColor
    #@ctx.fillRect(0, 0, @width, @height)
    #@ctx.restore()

  calculateRenderPriority: (space) =>
    val = 0
    if !space.selected
      val += 5
    switch @type
      when "Empty"       then val += 10
    val

  getHighestPrioritySpace: (edge) =>
    if !edge.neighbors[1]?
      edge.neighbors[0]
    else
      if @calculateRenderPriority(edge.neighbors[0]) <= @calculateRenderPriority(edge.neighbors[1])
        edge.neighbors[0]
      else
        edge.neighbors[1]

  fillGridSpace: (pos, space) =>
    space = {type: 'OutOfBounds'} if space is null

    @ctx.save()
    
    @ctx.beginPath()

    [x,y] = @worldToScreen(@hexCornerToWorld(pos, 5))
    @ctx.moveTo(x,y)

    for n in [0..5]
      [x,y] = @worldToScreen(@hexCornerToWorld(pos, n))
      @ctx.lineTo(x,y)

    @ctx.fillStyle = switch(space.type)
      when "OutOfBounds" then @color.bgOut
      when "Empty" then @color.bgIn
      else @color.error

    @ctx.fill()

    @ctx.restore()

  strokeGridSpace: (pos, space) =>
    @ctx.save()

    for n in [0..5]
      [x0,y0] = @worldToScreen(@hexCornerToWorld(pos, n-1))
      [x1,y1] = @worldToScreen(@hexCornerToWorld(pos, n))

      hipri = if(space? && space.edges[n]?)
        @getHighestPrioritySpace(space.edges[n])
      else
        null

      @ctx.beginPath()
      @ctx.strokeStyle =
        if hipri? and hipri.selected
          @color.lineSel
        else if hipri?
          @color.lineIn
        else
          @color.lineOut
      @ctx.moveTo(x0,y0)
      @ctx.lineTo(x1,y1)
      @ctx.closePath()
      @ctx.stroke()

    @ctx.restore()

  textGridSpace: (pos, space) =>
    @ctx.save()

    [x,y] = @worldToScreen(@hexCenterToWorld(pos))

    @ctx.fillStyle = @color.text
    @ctx.textAlign = "center"
    @ctx.font = "" + Math.floor(14 / @scale) + "px sans-serif"
    @ctx.fillText(space.type, x, y)
    @ctx.font = "" + Math.floor(12 / @scale) + "px sans-serif"
    @ctx.fillText("" + pos[0] + ", " + pos[1], x, y + Math.floor(30 / @scale))

    @ctx.restore()
  
  drawGridSpace: (pos, space) =>
    @fillGridSpace(pos, space)
    @strokeGridSpace(pos, space)
    if(space?)
      @textGridSpace(pos, space)

  drawGrid: (grid) =>
    gridSlice = grid.getRect(@screenToHex([0,0]),
                             @screenToHex([@width, 0]),
                             @screenToHex([0, @height]))
    while !(i = gridSlice.next()).done
      space = i.value
      @drawGridSpace(space.pos, space)

  pan: (dx, dy) =>
    [x,y] = @center
    @setCenter([x - dx * @scale,
                      y - dy * @scale])

  zoom: (pos, factor) =>
    [x,y] = @screenToWorld(pos)
    [cx,cy] = @center
    dx = (x - cx) / @scale
    dy = (y - cy) / @scale
    @adjustScaleBase(factor)
    @setCenter([x - (dx * @scale),
                      y - (dy * @scale)])
