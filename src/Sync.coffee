Action = require('ecstasy').Action
assert = require 'assert'

SpawnSystem =
  add: (engine) ->
    # Sets the boundary of the game
    engine.e().c 'pos',
      x: 0
      y: 0,
      radius: 1000
    .c 'boundary',{}
    .c 'render',
      fill: 'none'
      stroke: '#000'
    # Spawn 1000 blobs
    if engine.isServer
      for i in [0..1000]
        engine.aa 'spawn', null, null,
          x: Math.random()*2000-1000
          y: Math.random()*2000-1000
          radius: Math.random() * 10 + 8
          velX: Math.random()*60-30
          velY: Math.random()*60-30
          color: Math.random()*360

SpawnAction = Action.scaffold (engine) ->
  # Pre check
  assert @options
  assert typeof @options.x == 'number'
  assert typeof @options.y == 'number'
  assert typeof @options.radius == 'number'
  assert typeof @options.velX == 'number'
  assert typeof @options.velY == 'number'
  assert typeof @options.color == 'number'
  # Create entity
  @result = engine.e().c 'pos',
    x: @options.x
    y: @options.y
    radius: @options.radius
  .c 'blob',
    velX: @options.velX
    velY: @options.velY
    weight: @options.radius * @options.radius
  .c 'render',
    fill: "hsl(#{@options.color}, 100%, 75%)"
    stroke: "hsl(#{@options.color}, 100%, 60%)"
  .id

module.exports =
  system: SpawnSystem
  action: SpawnAction
