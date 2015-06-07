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
      engine.aa 'controlSplit', null, engine.player
    window.addEventListener 'mousemove', (e) ->
      rect = canvas.getBoundingClientRect()
      engine.aa 'playerMouse', null, engine.player,
      mouseX: e.clientX - rect.left - canvas.width / 2
      mouseY: e.clientY - rect.top - canvas.height / 2
    , false
  window.engine = engine
else
  # Server
  console.log 'server'
  engine = EngineBuilder.build true
  setInterval engine.update.bind(engine, 12), 12
module.exports = engine
