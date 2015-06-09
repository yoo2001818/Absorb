Action = require('ecstasy').Action
assert = require 'assert'

class ControlComponent
  constructor: ({@owner}) ->

ControlSystem =  
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'control', 'blob'
    @players = engine.e 'player'
  update: (delta) ->
    # Calculate average value of position
    groupList = {}
    for entity in @entities
      continue unless entity.c('control').owner?
      if not groupList[entity.c('control').owner]?
        groupList[entity.c('control').owner] =
          x: 0
          y: 0
          radius: 0
      group = groupList[entity.c('control').owner]
      entPos = entity.c 'pos'
      group.x += entPos.x * 1
      group.y += entPos.y * 1
      group.radius += 1
    for key, group of groupList
      group.x /= group.radius
      group.y /= group.radius
    for entity in @entities
      continue unless entity.c('control').owner?
      group = groupList[entity.c('control').owner]
      player = @engine.e(entity.c('control').owner).c 'player'
      continue unless group?
      continue unless player?
      entPos = entity.c 'pos'
      entBlob = entity.c 'blob'
      entBlob.velX += (player.mouseX - entBlob.velX) / 30
      entBlob.velY += (player.mouseY - entBlob.velY) / 30
      entBlob.velX += (group.x - entPos.x - entBlob.velX) / 30
      entBlob.velY += (group.y - entPos.y - entBlob.velY) / 30

ControlRenderSystem =
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'control', 'pos', 'blob'
  update: (delta) ->
    render = @engine.s 'render'
    return unless render.canvas?
    xSum = 0
    ySum = 0
    radiusSum = 0
    weightSum = 0
    for entity in @entities
      break unless @engine.player?
      continue unless entity.c('control').owner == @engine.player.id
      entPos = entity.c 'pos'
      entBlob = entity.c 'blob'
      xSum += entPos.x * entPos.radius
      ySum += entPos.y * entPos.radius
      radiusSum += entPos.radius
      weightSum += entBlob.weight
    if radiusSum > 0
      render.camera.x = xSum / radiusSum
      render.camera.y = ySum / radiusSum
      render.camera.ratio = Math.pow(render.canvas.width / 2 / 4 / Math.sqrt(weightSum), 0.6)
    else
      render.camera.x = 0
      render.camera.y = 0
      render.camera.ratio = 0.5

ControlSplitAction = Action.scaffold (engine) ->
  return unless engine.isServer
  assert @player?
  playerComp = @player.c 'player'
  angle = Math.atan2 playerComp.mouseY, playerComp.mouseX
  for entity in engine.s('control').entities
    if entity.c('blob').weight > 100 and entity.c('control').owner == @player.id
      # TODO On client side, this will return null.
      newEntity = engine.e engine.aa('blobSplit', entity, null, angle).result
      newEntity.c 'control', entity.c('control')
  @result = true

module.exports = 
  component: ControlComponent
  system: ControlSystem
  renderSystem: ControlRenderSystem
  action: ControlSplitAction
