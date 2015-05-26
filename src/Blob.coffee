Action = require('ecstasy').Action

class BlobComponent
  constructor: ({@velX, @velY, @parent, @weight, @weightCap, @invincible}) ->
    @velX ?= 0
    @velY ?= 0
    @weight ?= 0.15

square = (x) -> x * x

pushOther = (entity, other) ->
  [entPos, entBlob] = [entity.c('pos'), entity.c('blob')]
  [otherPos, otherBlob] = [other.c('pos'), other.c('blob')]
  # Run away from the other
  direction = Math.atan2 entPos.y - otherPos.y, entPos.x - otherPos.x
  vel = 1
  velX = vel * Math.cos direction
  velY = vel * Math.sin direction
  entBlob.velX += velX
  entBlob.velY += velY
  otherBlob.velX -= velX
  otherBlob.velY -= velY

BlobSystem =
  priority: 1500
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'blob', 'pos'
  update: (delta) ->
    for entity, i in @entities
      [entPos, entBlob] = [entity.c('pos'), entity.c('blob')]
      continue if entBlob.weight <= 0.1
      entPos.x += entBlob.velX / 1000 * delta
      entPos.y += entBlob.velY / 1000 * delta
      # Set velocity to min/max value
      preferredVelX = Math.min 30, Math.max -30, entBlob.velX
      preferredVelY = Math.min 30, Math.max -30, entBlob.velY
      entBlob.velX += (preferredVelX - entBlob.velX) / Math.pow 300, 1 * delta / 32
      entBlob.velY += (preferredVelY - entBlob.velY) / Math.pow 300, 1 * delta / 32
      entPos.radius = Math.sqrt entBlob.weight
      # Set weight to preferred weight
      if entBlob.weightCap 
        entBlob.weight += (entBlob.weightCap - entBlob.weight) / 4
        if Math.abs entBlob.weight - entBlob.weightCap < 3
          entBlob.weight = entBlob.weightCap
          entBlob.weightCap = null
        else continue
      if entBlob.invincible
        entBlob.invincible -= delta
        entBlob.invincible = null if entBlob.invincible < 0
        continue
      # TODO: Implement better algorithm of this, such as QuadTree
      for other, j in @entities
        continue unless j > i
        [otherPos, otherBlob] = [other.c('pos'), other.c('blob')]
        continue if otherBlob.weightCap
        if entBlob.parent == other.id
          entBlob.parent = null unless entPos.collides otherPos
          pushOther entity, other
          continue
        if otherBlob.parent == entity.id
          otherBlob.parent = null unless entPos.collides otherPos
          pushOther entity, other
          continue
        continue if otherBlob.weight <= 0.1
        continue if otherBlob.invincible
        if entPos.collides otherPos
          # Bigger one eats smaller one
          entityBig = entPos.radius > otherPos.radius
          [big, small] = if entityBig then [entity, other] else [other, entity]
          [bigPos, smallPos] = if entityBig then [entPos, otherPos] else [otherPos, entPos]
          [bigBlob, smallBlob] = if entityBig then [entBlob, otherBlob] else [otherBlob, entBlob]
          bigPos.radius = Math.sqrt bigBlob.weight
          smallPos.radius = Math.sqrt smallBlob.weight
          diff = bigPos.radius + smallPos.radius - bigPos.distance smallPos
          expectedWeight = square Math.max 0, smallPos.radius - diff
          expectedWeight = 0 if expectedWeight < 10
          weightGain = smallBlob.weight - expectedWeight
          weightGain /= 5 if weightGain > 10
          # Velocity sharing doesn't work as well as expected.
          #bigBlob.velX = (bigBlob.velX + smallBlob.velX) * bigBlob.weight / (bigBlob.weight + weightGain)
          #bigBlob.velY = (bigBlob.velY + smallBlob.velY) * bigBlob.weight / (bigBlob.weight + weightGain)
          bigBlob.weight += weightGain
          bigPos.radius = Math.sqrt bigBlob.weight
          smallBlob.weight -= weightGain
          smallBlob.weight = Math.max 0, smallBlob.weight
          smallPos.radius = Math.sqrt smallBlob.weight
    i = 0
    while i < @entities.length
      entity = @entities[i]
      if entity.c('blob').weight <= 0.1
        @engine.removeEntity entity
      else i++
    return

BlobSplitAction = Action.scaffold (engine) ->
  entPos = @entity.c 'pos'
  entBlob = @entity.c 'blob'
  entBlob.weight = entBlob.weightCap if entBlob.weightCap
  weight = entBlob.weight / 2
  direction = Math.random() * Math.PI * 2
  vel = 5 * Math.sqrt weight
  velX = vel * Math.cos direction
  velY = vel * Math.sin direction
  engine.e().c 'pos',
    x: entPos.x
    y: entPos.y
    radius: 1
  .c 'blob',
    velX: velX + entBlob.velX
    velY: velY + entBlob.velY
    parent: @entity.id
    weightCap: weight
    weight: 1
  .c 'render', @entity.c 'render'
  entBlob.weightCap = weight
  entBlob.velX = -velX
  entBlob.velY = -velY
  @result = 1

module.exports = 
  component: BlobComponent
  system: BlobSystem
  splitAction: BlobSplitAction
