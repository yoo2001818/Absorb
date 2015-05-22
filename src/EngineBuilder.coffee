ActionEngine = require './engine/ActionEngine'
Action = require './engine/Action'

build = (isServer) ->
  engine = new ActionEngine isServer
  engine.c 'player', require('./engine/PlayerComponent')
  engine.c 'pos', require('./Position')
  engine.c 'blob', require('./Blob').component
  engine.c 'boundary', require('./Boundary').component
  engine.c 'render', require('./Render').component
  
  engine.s 'blob', require('./Blob').system
  engine.s 'boundary', require('./Boundary').system
  engine.s 'render', require('./Render').system
  engine.s 'spawn', 
    onAddedToEngine: (engine) ->
      engine.e().c 'pos',
        x:0
        y:0,
        radius:240
      .c 'boundary',{}
      ###
      for(var i = 0; i < 200; ++i) {
        engine.e().c('pos', {
          x:Math.random()*400-200,
          y:Math.random()*400-200,
          radius:8
        }).c('blob', {
          velX:Math.random()*60-30,
          velY:Math.random()*60-30,
          weight: 64
        }).c('render', {});
      }
      ###
      engine.e().c 'pos',
        x:Math.random()*400-200
        y:Math.random()*400-200
      .c 'blob', 
        velX:Math.random()*60-30
        velY:Math.random()*60-30
        weight: 10000
      .c 'render', {}
  
  engine.a 'blobSplit', require('./Blob').splitAction
  
  return engine

module.exports.build = build
