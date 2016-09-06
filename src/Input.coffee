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
  constructor: (@gq, @rq) ->
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

  getPos: (e) =>
    [e.clientX, e.clientY]

  mouseMoveViewport: (e, m) =>
    @rq.q('pan', e.clientX - m.x, e.clientY - m.y)

  moveOnNotClick: () =>
    @rq.q('pan', @mouse.x - @mouse.saveX, @mouse.y - @mouse.saveY)
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
        pos = @rq.target.screenToHex(@getPos(e))
        @gq.q('toggleSelect', pos)
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

    @rq.q('zoom', pos, e.deltaY / 1000)
    undefined

  doListeners: (fn) =>
    fn("mousedown",   @onMouseDown)
    fn("mouseup",     @onMouseUp)
    fn("mousemove",   @onMouseMove)
    fn("wheel",       @onWheel)
    this

  activate: (el) =>
    @doListeners(el.addEventListener)

  deactivate: (el) =>
    @doListeners(el.removeEventListener)
