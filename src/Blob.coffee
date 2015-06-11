Action = require('ecstasy').Action
QuadTree = require('simple-quadtree')
Control = require('./Control')

class BlobComponent
  constructor: ({@velX, @velY, @group, @weight, @weightCap, @invincible}) ->
    @velX ?= 0
    @velY ?= 0
    @weight ?= 0.15

square = (x) -> x * x

BlobSystem =
  priority: 1500
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'blob', 'pos'
  update: (delta) ->
    weightSum = 0
    for entity in @entities
      entBlob = entity.c 'blob'
      weightSum += entBlob.weight
    # Create QuadTree, TODO should not use hard-coding
    quad = new QuadTree -10000, -10000, 10000*2, 10000*2,
      maxchildren: 10
    for entity, i in @entities
      [entPos, entBlob] = [entity.c('pos'), entity.c('blob')]
      continue if entBlob.weight <= 0.1
      entBlob.weight *= 0.99 if entBlob.weight > weightSum/3
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
        if Math.abs(entBlob.weight - entBlob.weightCap) < 3
          entBlob.weight = entBlob.weightCap
          entBlob.weightCap = null
      if entBlob.invincible
        entBlob.invincible -= delta
        entBlob.invincible = null if entBlob.invincible < 0
      entObj =
        x: entPos.x - entPos.radius
        y: entPos.y - entPos.radius
        w: entPos.radius * 2
        h: entPos.radius * 2
        entity: entity
      quad.get entObj, (obj) =>
        other = obj.entity
        return if other == entity
        [otherPos, otherBlob] = [other.c('pos'), other.c('blob')]
        if entBlob.group == otherBlob.group
          return if @engine.e(entBlob.group).c('group').time > 0
        return if otherBlob.weight <= 0.1
        return if entBlob.invincible
        return if otherBlob.invincible
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
          weightGain /= 2 if weightGain > 10
          # Velocity sharing doesn't work as well as expected.
          #bigBlob.velX = (bigBlob.velX + smallBlob.velX) * bigBlob.weight / (bigBlob.weight + weightGain)
          #bigBlob.velY = (bigBlob.velY + smallBlob.velY) * bigBlob.weight / (bigBlob.weight + weightGain)
          bigBlob.weight += weightGain
          bigBlob.weightCap += weightGain if bigBlob.weightCap?
          bigPos.radius = Math.sqrt bigBlob.weight
          smallBlob.weight -= weightGain
          smallBlob.weightCap -= weightGain if smallBlob.weightCap?
          smallBlob.weight = Math.max 0, smallBlob.weight
          smallPos.radius = Math.sqrt smallBlob.weight
      # Put entities into the quadtree
      quad.put entObj
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
  direction = @options
  if not direction?
    throw new Error 'options should be defined'
  vel = 40 * Math.sqrt weight
  velX = vel * Math.cos direction
  velY = vel * Math.sin direction
  newEntity = engine.e().c 'pos',
    x: entPos.x
    y: entPos.y
    radius: 1
  .c 'blob',
    velX: velX + entBlob.velX
    velY: velY + entBlob.velY
    group: @entity.c('blob').group
    weightCap: weight
    weight: 1
  .c 'render', @entity.c 'render'
  newEntity.c 'control', @entity.c 'control' if @entity.c 'control'
  entBlob.weightCap = weight
  entBlob.velX = -velX/6
  entBlob.velY = -velY/6
  engine.e(@entity.c('blob').group).c('group').time = 30000
  @result = newEntity.id

module.exports = 
  component: BlobComponent
  system: BlobSystem
  splitAction: BlobSplitAction
