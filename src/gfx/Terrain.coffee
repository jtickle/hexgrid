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

module.exports = class Terrain

  preRender: (draw) =>
    draw.ctx.save()

    # Blank, dark background
    draw.ctx.fillStyle = draw.color.bgOut
    draw.ctx.fillRect(0,0,draw.view.canvas.width,draw.view.canvas.height)

    draw.ctx.restore()
    undefined

  render: (draw, tile) =>
    r = tile.resources
    c = draw.color

    fill = switch
      when r.water > 0 then c.bgWater
      when r.rare  > 0 then c.bgRare
      when r.metal > 0 then c.bgMetal
      else r = c.bgNone

    stroke = draw.color.lineIn

    draw.fillstroke(tile, fill, stroke)

  postRender: (draw) =>
    undefined
