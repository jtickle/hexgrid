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

module.exports = class Input
  constructor: (@sq) ->
    @active = false

    @CLICK_TIMEOUT = 300
    @CLICK_THRESHOLD = 25

    @mouse =
      x:  0
      y:  0
      w:  0
      wm: 0
      l:  false
      m:  false
      r:  false
      a:  false
      b:  false

    @touch =
      touches: {}
      pinch: null
      average: null

  updateMouseData: (e) =>
    @mouse.x = e.clientX
    @mouse.y = e.clientY
    @mouse.l = (e.buttons & 1 == 1)
    @mouse.m = (e.buttons & 4 == 4) # [sic]
    @mouse.r = (e.buttons & 2 == 2) # [sic]
    @mouse.a = (e.buttons & 8 == 8)
    @mouse.b = (e.buttons & 16 == 16)

  updateTouchData: (e) =>
    e.preventDefault()
    myT = {}
    evT = e.touches
    avgX = 0
    avgY = 0
    cnt  = 0

    # Gather data from all touch points
    for t in evT
      do (t) ->
        return undefined if typeof(t) != 'object'

        myT[t.identifier] =
          x: t.clientX
          y: t.clientY

        avgX += t.clientX
        avgY += t.clientY
        cnt  += 1

    @touch.touches = myT

    # Calculate center of all touches
    if !cnt
      @touch.average = null
    else
      @touch.average =
        x: avgX / cnt
        y: avgY / cnt

    # If two touches, set Pinch Data
    if e.touches.length == 2
      pinch = {}
      swap = null

      pinch.x0 = e.touches[0].clientX
      pinch.x1 = e.touches[1].clientX
      pinch.y0 = e.touches[0].clientY
      pinch.y1 = e.touches[1].clientY

      pinch.dx = Math.abs(pinch.x0 - pinch.x1) / 2
      pinch.dy = Math.abs(pinch.y0 - pinch.y1) / 2

      pinch.r = Math.sqrt(pinch.dx*pinch.dx + pinch.dy*pinch.dy)

      @touch.pinch = pinch
    else
      @touch.pinch = null

  getPos: (e) =>
    [e.clientX, e.clientY]

  mouseMoveViewport: (e, m) =>
    @sq.q('pan', e.clientX - m.x, e.clientY - m.y)

  moveOnNotClick: () =>
    @sq.q('pan', @mouse.x - @mouse.saveX, @mouse.y - @mouse.saveY)
    delete @mouse.clickTimer
    delete @mouse.saveX
    delete @mouse.saveY

  onMouseDown: (e) =>
    if(e.buttons & 1)
      @mouse.saveX = e.clientX
      @mouse.saveY = e.clientY
      @mouse.clickTimer = setTimeout(@moveOnNotClick, @CLICK_TIMEOUT)
    @updateMouseData(e)
    undefined
  
  onMouseUp: (e) =>
    if(@mouse.l)
      if(@mouse.clickTimer)
        clearTimeout(@mouse.clickTimer)
        delete @mouse.clickTimer
        delete @mouse.saveX
        delete @mouse.saveY
        @sq.q('click', @getPos(e))
      else
        @mouseMoveViewport(e, @mouse)
    @updateMouseData(e)
    undefined

  onMouseMove: (e) =>
    if @mouse.l
      if @mouse.clickTimer?
        if(Math.sqrt(Math.pow(e.clientX - @mouse.saveX, 2) + Math.pow(e.clientY - @mouse.saveY, 2)) > @CLICK_THRESHOLD)
          clearTimeout(@mouse.clickTimer)
          @moveOnNotClick()
      else
        document.body.style.cursor = "move"
        @mouseMoveViewport(e, @mouse)
    else
      document.body.style.cursor = "default"
    @updateMouseData(e)
    undefined

  onWheel: (e) =>
    @mouse.w = e.deltaY
    @mouse.wm = e.deltaMode
    @updateMouseData(e)
    pos = @getPos(e)

    @sq.q('zoom', pos, e.deltaY / 1000)
    undefined

  onTouchStart: (e) =>
    updateTouchData e
    undefined

  onTouchMove: (e) =>
    pp = @touch.pinch
    pa = @touch.average
    updateTouchData e
    np = @touch.pinch
    na = @touch.average

    if e.touches.length > 0
      if e.touches.length == 2
        rq.q('zoom', (np.r - pp.r) / -100)
      rq.q('pan', na.x - pa.x, na.y - pa.y)
    undefined

  doListeners: (fn) =>
    fn("mousedown",   @onMouseDown)
    fn("mouseup",     @onMouseUp)
    fn("mousemove",   @onMouseMove)
    fn("wheel",       @onWheel)
    fn("touchstart",  @onTouchStart)
    fn("touchmove",   @onTouchMove)
    fn("touchend",    @onTouchMove)
    fn("touchcancel", @onTouchMove)
    this

  activate: (el) =>
    @doListeners(el.addEventListener)

  deactivate: (el) =>
    @doListeners(el.removeEventListener)
