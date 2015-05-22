class PositionComponent
  constructor: ({@x, @y, @radius}) ->
    @radius ?= 4
  distance: (other) ->
    xDiff = @x - other.x
    yDiff = @y - other.y
    return Math.sqrt xDiff * xDiff + yDiff * yDiff
  collides: (other) ->
    return @radius + other.radius > this.distance other

module.exports = PositionComponent
