ActionEngine = require('ecstasy').ActionEngine
Action = require('ecstasy').Action

build = (isServer) ->
  engine = new ActionEngine isServer
  engine.c 'player', require('./Player').component
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
  
  engine.a 'blobSplit', require('./Blob').splitAction
  engine.a 'controlSplit', require('./Control').action
  engine.a 'playerAdd', require('./Player').addAction
  engine.a 'playerMouse', require('./Player').mouseAction
  engine.a 'spawn', require('./Sync').action
  
  engine.s 'spawn', require('./Sync').system
  
  ## Test code for cameras
  engine.s 'camera',
    add: (engine) ->
      @engine = engine
      @entities = engine.e 'blob'
      @controls = engine.e 'control'
    update: (delta) ->
      if @controls.length == 0
        entity = @entities[0]
        return if entity.c 'control'
        entity.c 'control',
          owner: @engine.player.id
  ## Create a player object
  selfPlayer = engine.e engine.aa 'playerAdd', null, null,
    name: 'Player'
  engine.player = selfPlayer
  
  return engine

module.exports.build = build
