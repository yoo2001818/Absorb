class ControlComponent
  constructor: ({@owner}) ->

ControlSystem = 
  x: 0
  y: 0
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'control', 'blob'
  update: (engine) ->
    angle = Math.atan2 @y, @x
    dist = 2 * Math.min 80, Math.sqrt(@y*@y + @x*@x)
    x = dist * Math.cos angle
    y = dist * Math.sin angle
    for entity in @entities
      entBlob = entity.c 'blob'
      entBlob.velX += (x - entBlob.velX) / 30
      entBlob.velY += (y - entBlob.velY) / 30

module.exports = 
  component: ControlComponent
  system: ControlSystem
