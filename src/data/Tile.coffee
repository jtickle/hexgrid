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

Edge = require 'data/Edge'

module.exports = class Tile
  constructor: (@pos, @resources, @discovered) ->

    [q,r] = @pos

    @directions = [
      [q+1, r], [q+1, r-1], [q, r-1],
      [q-1, r], [q-1, r+1], [q, r+1]
    ]

    @structure = null

    @edges = [null,null,null,null,null,null]

    @selected = false

  connect: (grid) =>
    if(@grid?)
      throw 'Already Connected'
    @grid = grid

    for d, i in @directions
      t = @grid.getTile(d)
      @edges[i] = if !t? || !t.getOppositeEdge(i)
        new Edge(this)
      else
        t.getOppositeEdge(i).setNeighbor(this)
    undefined

  getEdge: (d) =>
    @edges[d%6]

  getOppositeEdge: (d) =>
    @getEdge(d+3)

  getNeighbor: (d) =>
    @edges[d].getNeighbor(this)

  getDirectionFromEdge: (e) =>
    @edges.indexOf(e)

  toJSON: () =>
    pos: @pos
    resources: @resources
    discovered: @discovered
    structure: @structure
    edges: @edges
    selected: @selected
