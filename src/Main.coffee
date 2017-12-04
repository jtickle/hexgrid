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

Grid        = require 'grid/Grid.coffee'
ActionQueue = require 'ActionQueue.coffee'
Input       = require 'Input.coffee'
Timer       = require 'Timer.coffee'
Stats       = require 'Stats.coffee'
Scene       = require 'gfx/Scene.coffee'

# Debugging function - shows a stat in the DOM
showStat = (id, n) ->
  document.getElementById('stats-' + id).textContent = n

# Debugging function - shows all stats from a Stats object in the DOM
showAllStats = (stats) ->
  for stat in stats.stats
    showStat stat, stats.getAverage(stat)

run = () ->
  # Game Database
  grid     = new Grid(16)

  # Scene Controller
  scene    = new Scene('hexgrid', 50, grid)

  # Action Queue
  sq       = new ActionQueue(scene)

  # Input Driver
  input    = new Input(sq)

  # Debugging Timer
  timer    = new Timer(1000)

  # Debgging Stats
  stats    = new Stats(timer, ['update', 'render', 'frame'])

  # Input library attempts to be generic.  This space is for queueing
  # up scene events in reaction to input handlers.  Probably should
  # do this better.
  input.addEventListener "pan", sq.qfn 'pan'
  input.addEventListener "click", sq.qfn 'click'
  input.addEventListener "zoom", sq.qfn 'zoom'
  input.addEventListener "resize", sq.qfn 'resize'

  # Connect input driver to main canvas
  input.activate scene.canvas

  animate  = (ct) ->

    # Calculate time in seconds since last animation began using
    # time provided by requestAnimationFrame, saves a date lookup
    dt = if timer.empty() then ct else timer.pop ct

    # Save current rAF time
    timer.push ct

    # Start a timer for how long it takes to actually process
    # a whole frame
    stats.time 'frame', () ->

      # Process the scene queue
      stats.time 'update', () -> sq.process()

      # Render the Scene
      stats.time 'render', () -> scene.render(dt)

      # If a second has passed since last update, calculate averages
      # and update the dom
      sec = Math.floor ct/1000
      if sec != stats.currentSecond

        # Calculate average over 1s and update DOM with result
        showStat 'fps', stats.counts['frame']
        showAllStats(stats)

        # Reset counters
        stats.reset sec;

    # Continue the game loop
    requestAnimationFrame animate

  # Begin game loop
  requestAnimationFrame animate

# Run the game after content is loaded
document.addEventListener 'DOMContentLoaded', () ->
  run()
