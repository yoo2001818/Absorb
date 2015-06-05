Action = require('ecstasy').Action

class ControlComponent
  constructor: ({@owner}) ->

ControlSystem =  
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'control', 'blob'
  update: (delta) ->
    for entity in @entities
      continue unless entity.c('control').owner?
      player = @engine.e(entity.c('control').owner)
      continue unless player?
      entBlob = entity.c 'blob'
      entBlob.velX += (player.mouseX - entBlob.velX) / 30
      entBlob.velY += (player.mouseY - entBlob.velY) / 30

ControlRenderSystem =
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'control', 'pos', 'blob'
  update: (delta) ->
    render = @engine.s 'render'
    xSum = 0
    ySum = 0
    radiusSum = 0
    for entity in @entities
      entPos = entity.c 'pos'
      entBlob = entity.c 'blob'
      xSum += entPos.x
      ySum += entPos.y
      radiusSum += entBlob.weight
    if @entities.length > 0
      render.camera.x = xSum / @entities.length
      render.camera.y = ySum / @entities.length
      render.camera.ratio = Math.pow(render.canvas.width / 2 / 10 / Math.sqrt(radiusSum), 0.6)
    else
      render.camera.x = 0
      render.camera.y = 0
      render.camera.ratio = 0.5
    for entity in @entities
      entPos = entity.c 'pos'
      entBlob = entity.c 'blob'
      entBlob.velX += (xSum / @entities.length - entPos.x - entBlob.velX) / 30
      entBlob.velY += (ySum / @entities.length - entPos.y - entBlob.velY) / 30

ControlSplitAction = Action.scaffold (engine) ->
  system = engine.s 'control'
  angle = Math.atan2 system.y, system.x
  for entity in system.entities
    if entity.c('blob').weight > 100
      newEntity = engine.e engine.aa 'blobSplit', entity, null, angle
      newEntity.c 'control', {}

module.exports = 
  component: ControlComponent
  system: ControlSystem
  renderSystem: ControlRenderSystem
  action: ControlSplitAction
