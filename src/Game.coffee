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

GridData      = require 'data/Grid.coffee'
ViewportData  = require 'data/Viewport.coffee'

TerrainGfx    = require 'gfx/Terrain.coffee'
UiGfx         = require 'gfx/Ui.coffee'

ViewportLogic = require 'logic/Viewport.coffee'
TileLogic     = require 'logic/Tile.coffee'
UiLogic       = require 'logic/Ui.coffee'

ActionQueue   = require 'util/ActionQueue.coffee'
Input         = require 'util/Input.coffee'
Timer         = require 'util/Timer.coffee'
Stats         = require 'util/Stats.coffee'
Draw          = require 'util/Draw.coffee'

module.exports = class Game
  constructor: (config) ->

    # Set up Game Data
    @state =
      'grid': new GridData config.gridRadius
      'viewport': new ViewportData config.domId

    # Input driver
    @input = new Input()

    # Drawer
    @draw = new Draw(@state.viewport, config.gridDrawRadius)

    # Set up Action Handlers
    @queue = new ActionQueue()
    @vpLogic = new ViewportLogic(@state)
    @tileLogic = new TileLogic(@state, @draw)
    @uiLogic = new UiLogic(@state, @draw)
    @vpLogic.registerHandlerWith(@queue.registerAction)
    @tileLogic.registerHandlerWith(@queue.registerAction)
    @uiLogic.registerHandlerWith(@queue.registerAction)

    # Set up Renderers
    @renderers = [
      new TerrainGfx(),
      new UiGfx()
    ]

    # Debugging timer
    @timer = new Timer config.debugTimer

    # Debugging stats
    @stats = new Stats @timer, ['update', 'render']

    # Current second for stat keeping
    @currentSecond = 0

    # Input library attempts to be generic.  This space is for queueing
    # up scene events in reaction to input handlers.  Probably should
    # do this better.
    @input.addEventListener "pan", @queue.qfn 'viewport.pan'
    @input.addEventListener "click", @queue.qfn 'tile.click'
    @input.addEventListener "zoom", @queue.qfn 'viewport.zoom'
    @input.addEventListener "resize", @queue.qfn 'viewport.resize'

    # Connect input driver to main canvas
    @input.activate @state.viewport.canvas

    @input.onResize()

  loop: () =>
    requestAnimationFrame @update

  render: (dt) =>
    @stats.time 'render', () =>
      g = @state.grid.getRectBorder(
        @draw.screenToHex([0 , 0]), # vertex
        @draw.screenToHex([0 + @state.viewport.width , 0]), # maxQ
        @draw.screenToHex([0 , 0 + @state.viewport.height]), # maxR
        1) # padding

      for renderer in @renderers
        renderer.preRender(@draw, g)
      for renderer in @renderers
        for tile in g
          renderer.render(@draw, tile)
      for renderer in @renderers
        renderer.postRender(@draw, g)

    @loop()

  update: (ct) =>
    # Calculate time in seconds since last animation began using
    # time provided by requestAnimationFrame, saves a date lookup
    dt = if @timer.empty() then ct else @timer.pop ct

    # Save current rAF time
    @timer.push ct

    # Process the scene queue
    @stats.time 'update', () => @queue.process()

    # If a second has passed since last update, calculate averages
    # and update the dom
    sec = Math.floor ct/1000
    if sec != @currentSecond
      @queue.q 'ui.stats.update', @stats.snapshot()
      @stats.reset()
      @currentSecond = sec

    # Continue the game loop
    @render(dt)
