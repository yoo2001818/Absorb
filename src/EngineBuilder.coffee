ActionEngine = require('ecstasy').ActionEngine
Action = require('ecstasy').Action

build = (isServer) ->
  engine = new ActionEngine isServer
  engine.c 'player', require('./Player').player
  engine.c 'pos', require('./Position')
  engine.c 'blob', require('./Blob').component
  engine.c 'boundary', require('./Boundary').component
  engine.c 'render', require('./Render').component
  engine.c 'control', require('./Control').component
  
  engine.s 'blob', require('./Blob').system
  engine.s 'boundary', require('./Boundary').system
  engine.s 'render', require('./Render').system
  engine.s 'control', require('./Control').system
  engine.s 'controlRender', require('./Control').renderSystem
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
      @controls = engine.e 'control'
    update: (delta) ->
      if @controls.length == 0
        entity = @entities[0]
        entity.c 'control', {} unless entity.c 'control'
  
  engine.a 'blobSplit', require('./Blob').splitAction
  engine.a 'controlSplit', require('./Control').action
  engine.a 'playerMouse', require('./Player').mouseAction
  
  return engine

module.exports.build = build
