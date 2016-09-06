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

Renderer    = require 'Renderer'
Grid        = require 'grid/Grid'
ActionQueue = require 'ActionQueue'
Input       = require 'Input'

run = () ->
  renderer = new Renderer('hexgrid', 50)
  rq       = new ActionQueue(renderer)
  grid     = new Grid(4)
  gq       = new ActionQueue(grid)
  input    = new Input(gq, rq)

  pt       = 0

  window.addEventListener "resize", () ->
    rq.q('blank')
    rq.q('drawGrid', grid)

  stats =
    cursec: 0
    count: 0
    dt:
      f: 0
      b: 0
      g: 0
      r: 0

  timers = []

  time =
    begin: () ->
      timers.push(Date.now())
    end: () ->
      (Date.now() - timers.pop()) / 1000

  floor5 = (n) ->
    Math.floor(n * 1000) / 1000

  justShowStat = (id, n) ->
    document.getElementById('stats-' + id).textContent = n

  showStat = (id, n, count) ->
    justShowStat(id, floor5(n / count))

  animate  = (ct) ->
    dt = (ct - pt) / 1000

    time.begin()
    stats.dt.f += floor5(dt)

    if dt < 0 then return

    rq.q('blank')
    rq.q('drawGrid', grid)

    time.begin()
    gq.process()
    stats.dt.g += time.end()

    time.begin()
    rq.process()
    stats.dt.r += time.end()

    # Calculate FPS
    stats.count++
    sec = Math.floor(ct/1000)
    if sec != stats.cursec
      justShowStat('fps', stats.count)
      showStat('dt_f', stats.dt.f, stats.count)
      showStat('dt_g', stats.dt.g, stats.count)
      showStat('dt_r', stats.dt.r, stats.count)
      showStat('dt_t', stats.dt.t, stats.count)
      stats.cursec = sec
      stats.count = 0
      stats.dt.f = 0
      stats.dt.g = 0
      stats.dt.r = 0
      stats.dt.t = 0

    pt = ct

    stats.dt.t += time.end()
    timers.length = 0

    requestAnimationFrame(animate)

  input.activate(renderer.view)
  animate(0)


document.addEventListener 'DOMContentLoaded', () ->
  run()
