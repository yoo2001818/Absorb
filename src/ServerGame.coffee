EngineBuilder = require './EngineBuilder' 

module.exports = (io) ->
  console.log 'Starting game engine'
  engine = EngineBuilder.build true 
  console.log 'Hooking protocols to game engine'
  setInterval () ->
    engine.update(12)
  , 12
  io.on 'connection', (socket) ->
    
  console.log 'Started accepting sockets'