ActionEngine = require('ecstasy').ActionEngine
Action = require('ecstasy').Action

build = (isServer) ->
  engine = new ActionEngine isServer
  # engine.c 'player', require('./engine/PlayerComponent')
  engine.c 'pos', require('./Position')
  engine.c 'blob', require('./Blob').component
  engine.c 'boundary', require('./Boundary').component
  engine.c 'render', require('./Render').component
  
  engine.s 'blob', require('./Blob').system
  engine.s 'boundary', require('./Boundary').system
  engine.s 'render', require('./Render').system
  engine.s 'spawn', 
    add: (engine) ->
      engine.e().c 'pos',
        x: 0
        y: 0,
        radius: 1000
      .c 'boundary',{}
      .c 'render',
        fill: 'none'
        stroke: '#000'
      for i in [0..1000]
        radius = Math.random() * 10 + 8
        engine.e().c 'pos', 
          x: Math.random()*2000-1000
          y: Math.random()*2000-1000
          radius: radius
        .c 'blob',
          velX: Math.random()*60-30
          velY: Math.random()*60-30
          weight: radius*radius
        .c 'render', {} 
      ###
      engine.e().c 'pos',
        x:Math.random()*400-200
        y:Math.random()*400-200
      .c 'blob', 
        velX:Math.random()*60-30
        velY:Math.random()*60-30
        weight: 10000
      .c 'render', {}
      ###
  ## Test code for cameras
  engine.s 'camera',
    add: (engine) ->
      @engine = engine
      @entities = engine.e 'blob'
    update: (delta) ->
      render = engine.s 'render'
      render.camera.x = @entities[0].c('pos').x
      render.camera.y = @entities[0].c('pos').y
  
  engine.a 'blobSplit', require('./Blob').splitAction
  
  return engine

module.exports.build = build
