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
      @x = 0
      @y = 0
    update: (delta) ->
      entity = @entities[0]
      render = engine.s 'render'
      render.camera.x = entity.c('pos').x
      render.camera.y = entity.c('pos').y
      render.camera.ratio = Math.pow(render.canvas.width / 2 / 10 / entity.c('pos').radius, 0.6)
      entity.c('blob').velX += (@x - entity.c('blob').velX) / 100
      entity.c('blob').velY += (@y - entity.c('blob').velY) / 100
  
  engine.a 'blobSplit', require('./Blob').splitAction
  
  return engine

module.exports.build = build
