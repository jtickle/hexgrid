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

Edge = require 'grid/Edge'

module.exports = class Space
  constructor: (@pos, @type) ->

    [q,r] = @pos

    @priority = switch @type
      when "OutOfBounds" then 999
      when "Empty"       then 0

    @directions = [
      [q+1, r], [q+1, r-1], [q, r-1],
      [q-1, r], [q-1, r+1], [q, r+1]
    ]

    @edges = [null,null,null,null,null,null]

  connect: (grid) =>
    if(@grid?)
      throw 'Already Connected'
    @grid = grid

    if @type == "OutOfBounds"
      for d, i in @directions
        s = @grid.getSpace(d, false)
        if s? and s.type != "OutOfBounds" and s.edges[(i+3)%6]?
          @edges[i] = s.edges[(i+3)%6]
    else
      for d, i in @directions
        s = @grid.getSpace(d)
        @edges[i] = if !s? or s.type == "OutOfBounds" or !s.edges[(i+3)%6]?
          new Edge(this)
        else
          s.edges[(i+3)%6].setNeighbor(this)

  getNeighbor: (d) =>
    @edges[d].getNeighbor(this)

  getDirectionFromEdge: (e) =>
    @edges.indexOf(e)
