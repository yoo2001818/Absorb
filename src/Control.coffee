class ControlComponent
  constructor: ({@owner}) ->

ControlSystem = 
  x: 0
  y: 0
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'control', 'blob'
  update: (engine) ->
    for entity in @entities
      entBlob = entity.c 'blob'
      entBlob.velX += (@x - entBlob.velX) / 100
      entBlob.velY += (@y - entBlob.velY) / 100

module.exports = 
  component: ControlComponent
  system: ControlSystem
