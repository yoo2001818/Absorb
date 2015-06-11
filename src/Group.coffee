Action = require('ecstasy').Action
assert = require './Assert'

class GroupComponent
  constructor: ({@time, @entities}) ->
    @time ?= 0
    @entities ?= []

GroupSystem = 
  add: (engine) ->
    @engine = engine
    @groups = engine.getEntitiesFor 'group'
    @entities = engine.getEntitiesFor 'blob'
    @entityComp = engine.getComponentGroup @entities
    @entityComp.on 'entityAdded', (entity) =>
      # Add the entity to group
      entityBlob = entity.c 'blob'
      return unless entityBlob.group?
      groupEnt = @engine.e entityBlob.group
      return unless groupEnt?
      group = groupEnt.c 'group'
      return unless group.entities.indexOf(entity.id) == -1
      group.entities.push entity.id
    @entityComp.on 'entityRemoved', (entity) =>
      # Remove the entity from group
      entityBlob = entity.c 'blob'
      return unless entityBlob.group?
      groupEnt = @engine.e entityBlob.group
      return unless groupEnt?
      group = groupEnt.c 'group'
      index = group.entities.indexOf entity.id
      group.entities.splice index, 1
      if group.entities.length == 0
        engine.removeEntity group
  update: (delta) ->
    # Push each other
    for groupEnt in @groups
      group = groupEnt.c 'group'
      group.time -= delta
      if group.time < 0
        group.time = 0
        continue
      index = 0
      while index < group.entities.length
        entity = @engine.e group.entities[index]
        otherIndex = index+1
        while otherIndex < group.entities.length
          other = @engine.e group.entities[otherIndex]
          pushOther entity, other
          otherIndex++
        index++
    
pushOther = (entity, other) ->
  [entPos, entBlob] = [entity.c('pos'), entity.c('blob')]
  [otherPos, otherBlob] = [other.c('pos'), other.c('blob')]
  # Run away from the other
  return unless entPos.collides otherPos
  direction = Math.atan2 entPos.y - otherPos.y, entPos.x - otherPos.x
  radiusSum = entPos.radius + otherPos.radius
  collisionX = (entPos.x * otherPos.radius + otherPos.x * entPos.radius) / radiusSum
  collisionY = (entPos.y * otherPos.radius + otherPos.y * entPos.radius) / radiusSum
  entPos.x = collisionX + Math.cos(direction) * entPos.radius
  entPos.y = collisionY + Math.sin(direction) * entPos.radius
  otherPos.x = collisionX - Math.cos(direction) * otherPos.radius
  otherPos.y = collisionY - Math.sin(direction) * otherPos.radius
  vel = 30
  velX = vel * Math.cos direction
  velY = vel * Math.sin direction
  entBlob.velX += (velX-entBlob.velX)/10
  entBlob.velY += (velY-entBlob.velY)/10
  otherBlob.velX += (-velX-otherBlob.velX)/10
  otherBlob.velY += (-velY-otherBlob.velY)/10
  
module.exports = 
  component: GroupComponent
  system: GroupSystem