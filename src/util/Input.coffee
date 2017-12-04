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
  constructor: () ->
    # After this many ms, a click is no longer a click
    @CLICK_TIMEOUT = 300

    # How far the mouse can move and still be considered a click
    @CLICK_THRESHOLD = 25

    # Current mouse data
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

    # Current touch data
    @touch =
      touches: {}
      pinch: null
      average: null

    # Event listeners
    @listeners = {}

  # Listen for an Input event
  addEventListener: (event, fn) =>
    if !@listeners[event]?
      @listeners[event] = []
    if(@listeners[event].indexOf(fn) < 0)
      @listeners[event].push(fn)

  # Remove listener from Input event
  removeEventListener: (event, fn) =>
    if !@listeners[event]?
      return
    idx = @listeners[event].indexOf(fn)
    if idx < 0
      return
    @listeners[event].splice(idx, 1)

  # Trigger an event
  emitEvent: (event, m...) =>
    if !@listeners[event]?
      return
    for fn in @listeners[event]
      fn m...

  # Updates current mouse data from all mouse events
  updateMouseData: (e) =>
    @mouse.x = e.clientX
    @mouse.y = e.clientY
    @mouse.l = (e.buttons & 1 == 1)
    @mouse.m = (e.buttons & 4 == 4) # [sic]
    @mouse.r = (e.buttons & 2 == 2) # [sic]
    @mouse.a = (e.buttons & 8 == 8)
    @mouse.b = (e.buttons & 16 == 16)

  # Updates current touch data from all touch events
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

        # Create a touch point
        myT[t.identifier] =
          x: t.clientX
          y: t.clientY

        # Update the center of all touch points
        avgX += t.clientX
        avgY += t.clientY
        cnt  += 1

    # Store touch points
    @touch.touches = myT

    # Calculate center of all touches
    if !cnt
      @touch.average = null
    else
      @touch.average = [avgX / cnt, avgY / cnt]

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

      # Thanks, Pythagoras
      pinch.r = Math.sqrt(pinch.dx*pinch.dx + pinch.dy*pinch.dy)

      @touch.pinch = pinch
    else
      @touch.pinch = null

  # Just get the position from a mouse event
  getPos: (e) =>
    [e.clientX, e.clientY]

  # It has been decided that this is a mouse move
  mouseMoveViewport: (e, m) =>
    @emitEvent 'pan', e.clientX - m.x, e.clientY - m.y

  # It has been decided that this is a mouse click
  moveOnNotClick: () =>
    @emitEvent 'pan', @mouse.x - @mouse.saveX, @mouse.y - @mouse.saveY
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
        @emitEvent 'click', @getPos e
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

    @emitEvent 'zoom', @getPos(e), e.deltaY / 1000
    undefined

  onTouchStart: (e) =>
    @updateTouchData e
    undefined

  onTouchMove: (e) =>
    pp = @touch.pinch
    pa = @touch.average
    @updateTouchData e
    np = @touch.pinch
    na = @touch.average

    if e.touches.length > 0
      if e.touches.length == 2
        @emitEvent 'zoom', pa, (np.r - pp.r) / -100
      @emitEvent 'pan', na[0] - pa[0], na[1] - pa[1]
    undefined

  onResize: (e) =>
    @emitEvent('resize', document.documentElement.clientWidth,
                         document.documentElement.clientHeight)

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
    window.addEventListener "resize", @onResize
    @onResize()

  deactivate: (el) =>
    @doListeners(el.removeEventListener)
    window.removeEventListener "resize", @onResize
