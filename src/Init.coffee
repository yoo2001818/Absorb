# Entry point of the application
EngineBuilder = require './EngineBuilder' 
engine = null

if window? 
  # Client
  console.log 'client'
  engine = EngineBuilder.build true # Single player local game acts as server
  window.onload = () ->
    canvas = document.getElementById 'canvas'
    canvas.width = 640
    canvas.height = 480
    engine.s('render').canvas = canvas
    prevTime = new Date().getTime()
    animationLoop = () ->
      window.requestAnimationFrame animationLoop
      newTime = new Date().getTime()
      engine.update newTime - prevTime
      prevTime = newTime
    animationLoop()
  window.onclick = () ->
    for entity in engine.e 'blob', 'pos'
      engine.aa 'blobSplit', null, entity if entity.c('pos').radius > 20
    return
  window.engine = engine
else
  # Server
  console.log 'server'
  engine = EngineBuilder.build true
  setInterval engine.update.bind(engine, 100), 100
module.exports = engine
