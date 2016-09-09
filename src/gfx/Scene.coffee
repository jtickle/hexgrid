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

CanvasLayers = require('gfx/CanvasLayers')
Terrain      = require('gfx/Terrain')
Structures   = require('gfx/Structures')
Entities     = require('gfx/Entities')
Ui           = require('gfx/Ui')
HexMath      = require('gfx/HexMath')
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

  resizeNotify: []

  constructor: (@domId, @gridRadius, @grid) ->
    @canvas = document.getElementById(@domId)
    @ctx    = @canvas.getContext('2d')

    @hm  = new HexMath(@gridRadius)
    @tfm = new Transforms(this)

    @terrain = new Terrain(this)
    @structures = new Structures(this)
    @entities = new Entities(this)
    @ui = new Ui(this)

    @terrainLayer = new CanvasLayers.Container(@canvas, true)
    @container = @terrainLayer
    @terrainLayer.onRender = @terrain.onRender
    @resizeNotify.push(@terrainLayer)

    @structuresLayer = new CanvasLayers.Layer(0, 0, 100, 100)
    @structuresLayer.onRender = @structures.onRender
    @terrainLayer.getChildren().add(@structuresLayer)
    @resizeNotify.push(@structuresLayer)
    
    @entitiesLayer = new CanvasLayers.Layer(0, 0, 100, 100)
    @entitiesLayer.onRender = @entities.onRender
    @structuresLayer.getChildren().add(@entitiesLayer)
    @resizeNotify.push(@entitiesLayer)

    @uiLayer = new CanvasLayers.Layer(0, 0, 100, 100)
    @uiLayer.onRender = @ui.onRender
    @entitiesLayer.getChildren().add(@uiLayer)
    @resizeNotify.push(@uiLayer)

    @resize()
    window.addEventListener("resize", @resize)

  render: (dt) =>
    @dt = dt
    @container.redraw()

  pan: (dx, dy) =>

  zoom: (ds) =>

  resize: () =>
    @width = document.documentElement.clientWidth
    @height = document.documentElement.clientHeight

    @resizeNotify.map (v) =>
      v.rect.width = @width
      v.rect.height = @height
      

    console.log(@resizeNotify)
    @container.markRectsDamaged()
    undefined

