# Entry point of the application
EngineBuilder = require './EngineBuilder' 
engine = null

if window? 
  # Client
  console.log 'client'
  engine = EngineBuilder.build true # Single player local game acts as server
  window.onload = () ->
    canvas = document.getElementById 'canvas'
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight
    engine.s('render').canvas = canvas
    prevTime = new Date().getTime()
    animationLoop = () ->
      window.requestAnimationFrame animationLoop
      newTime = new Date().getTime()
      engine.update newTime - prevTime
      prevTime = newTime
    animationLoop()
    window.onresize = () ->
      canvas.width = window.innerWidth
      canvas.height = window.innerHeight
    window.onclick = () ->
      for entity in engine.e 'blob', 'pos'
        engine.aa 'blobSplit', null, entity if entity.c('pos').radius > 20
      return
    window.addEventListener 'mousemove', (e) ->
      rect = canvas.getBoundingClientRect()
      engine.s('control').x = e.clientX - rect.left - canvas.width / 2
      engine.s('control').y = e.clientY - rect.top - canvas.height / 2
    , false
  window.engine = engine
else
  # Server
  console.log 'server'
  engine = EngineBuilder.build true
  setInterval engine.update.bind(engine, 100), 100
module.exports = engine
