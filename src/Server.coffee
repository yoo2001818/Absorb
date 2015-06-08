EngineBuilder = require './EngineBuilder' 

console.log 'server'
engine = EngineBuilder.build true
setInterval () ->
  engine.update(12)
, 12
