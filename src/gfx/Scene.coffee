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

Terrain      = require('gfx/Terrain')
Structures   = require('gfx/Structures')
Entities     = require('gfx/Entities')
Ui           = require('gfx/Ui')
HexMath      = require('gfx/HexMath')
HexDraw      = require('gfx/HexDraw')
Transforms   = require('gfx/Transforms')

module.exports = class Scene
  center:    [0,0]
  scaleBase:  0
  scale:      1
  width:      0
  height:     0
  color:
    bgOut:   '#333'
    bgIn:    '#CCC'
    lineOut: '#222'
    lineIn:  '#333'
    lineSel: '#0C0'
    error:   '#F00'
    text:    '#333'

  constructor: (@domId, @gridRadius, @grid) ->
    @canvas = document.getElementById(@domId)
    @ctx    = @canvas.getContext('2d')

    @hm  = new HexMath(@gridRadius)
    @tfm = new Transforms(this)
    @hd  = new HexDraw(this)

    @terrain = new Terrain(this)
    @structures = new Structures(this)
    @entities = new Entities(this)
    @ui = new Ui(this)

    @resize()
    window.addEventListener("resize", @resize)

  render: (dt) =>
    @dt = dt

    g = @grid.getRect(@tfm.screenToHex([0         , 0          ]), # vertex
                      @tfm.screenToHex([0 + @width, 0          ]), # maxQ
                      @tfm.screenToHex([0         , 0 + @height])) # maxR

    @terrain.render(g)
    @structures.render(g)
    @entities.render(g)
    @ui.render(g)

  setCenter: (pos) =>
    @center = pos

  setScaleBase: (s) =>
    @scaleBase = s
    @scale = Math.pow(Math.E, @scaleBase)
    this

  adjustScaleBase: (ds) =>
    @setScaleBase(@scaleBase + ds)
    this

  pan: (dx, dy) =>
    [x,y] = @center
    @setCenter([x - dx * @scale,
                y - dy * @scale])

  zoom: (pos, ds) =>
    console.log('zoom', pos, ds)
    [x,y] = @tfm.screenToWorld(pos)
    [cx,cy] = @center
    console.log(x, y, cx, cy, @scale)
    dx = (x - cx) / @scale
    dy = (y - cy) / @scale
    console.log(dx, dy)
    @adjustScaleBase(ds)
    @setCenter([x - (dx * @scale),
                y - (dy * @scale)])

  click: (pos) =>
    pos = @tfm.screenToHex(pos)
    @grid.toggleSelect(pos)
    undefined

  resize: () =>
    @width = document.documentElement.clientWidth
    @height = document.documentElement.clientHeight
    @canvas.width = @width
    @canvas.height = @height
      
    undefined

