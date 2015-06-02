Action = require('ecstasy').Action

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

ControlSplitAction = Action.scaffold (engine) ->
  system = engine.s 'control'
  angle = Math.atan2 system.y, system.x
  for entity in system.entities
    engine.aa 'blobSplit', entity, null, angle

module.exports = 
  component: ControlComponent
  system: ControlSystem
  action: ControlSplitAction