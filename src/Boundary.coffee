class BoundaryComponent

BoundarySystem = 
  onAddedToEngine: (engine) ->
    @engine = engine
    @boundaries = engine.e 'boundary', 'pos'
    @entities = engine.e 'blob', 'pos'
  update: (delta) ->
    return if not @boundaries.length > 0
    boundary = @boundaries[0].c 'pos' # TODO Only 1st object is used; should be changed
    for entity in @entities
      entPos = entity.c 'pos'
      entBlob = entity.c 'blob'
      dist = entPos.distance boundary
      maxDist = boundary.radius - entPos.radius
      diff = dist - maxDist
      continue if diff <= 0
      angle = Math.atan2 entPos.y - boundary.y, entPos.x - boundary.x
      cos = Math.cos angle
      sin = Math.sin angle
      entPos.x = boundary.x + maxDist * Math.cos angle
      entPos.y = boundary.y + maxDist * Math.sin angle
      # Transform to 0deg
      vx = entBlob.velX * cos + entBlob.velY * sin
      vy = entBlob.velY * cos - entBlob.velX * sin
      # Modify to velocity
      vx = -vx
      # Revert transform
      entBlob.velX = vx * cos - vy * sin
      entBlob.velY = vy * cos + vx * sin
      return

module.exports =
  component: BoundaryComponent
  system: BoundarySystem
