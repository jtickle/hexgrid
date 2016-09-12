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
HexGrid      = require('gfx/HexGrid')
Transforms   = require('gfx/Transforms')

module.exports = class Scene
  center:    [0,0]
  scaleBase:  0
  scale:      1
  width:      0
  height:     0
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

  constructor: (@domId, @gridRadius, @grid) ->
    @canvas = document.getElementById(@domId)
    @ctx    = @canvas.getContext('2d')

    @tfm = new Transforms(this)
    @hex  = new HexGrid(this)

    @terrain    = new Terrain(this)
    @structures = new Structures(this)
    @entities   = new Entities(this)
    @ui         = new Ui(this)

    @resize()
    window.addEventListener("resize", @resize)

  render: (dt) =>
    @dt = dt

    g = @grid.getRectBorder(@hex.screenToHex([0         , 0          ]), # vertex
                            @hex.screenToHex([0 + @width, 0          ]), # maxQ
                            @hex.screenToHex([0         , 0 + @height]), # maxR
                            1)                                           # border

    @terrain.preRender()
    @structures.preRender()
    @entities.preRender()
    @ui.preRender()

    tiles = @ui.render(@entities.render(@structures.render(@terrain.render(g))))
    while !(i = tiles.next()).done
      undefined

    @terrain.postRender()
    @structures.postRender()
    @entities.postRender()
    @ui.postRender()

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
    [x,y] = @tfm.screenToWorld(pos)
    [cx,cy] = @center
    dx = (x - cx) / @scale
    dy = (y - cy) / @scale
    @adjustScaleBase(ds)
    @setCenter([x - (dx * @scale),
                y - (dy * @scale)])

  click: (pos) =>
    pos = @hex.screenToHex(pos)
    @grid.toggleSelect(pos)
    undefined

  resize: () =>
    @width = document.documentElement.clientWidth
    @height = document.documentElement.clientHeight
    @canvas.width = @width
    @canvas.height = @height
      
    undefined
