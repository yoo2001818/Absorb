EngineBuilder = require './EngineBuilder' 
Action = require('ecstasy').Action
# Client
if io?
  spectate = confirm '관전할래요?'
  nickname = prompt '닉네임 뭐로 할래요?' unless spectate
  socket = io null
  engine = EngineBuilder.build false
  socket.on 'connect', () ->
    socket.emit 'init', nickname unless spectate
  # Wait for Engine data
  socket.on 'engine', (data) ->
    engine.deserialize data
  socket.on 'action', (data) ->
    engine.a Action.deserialize(engine, data)
  socket.on 'player', (id) ->
    engine.player = engine.e id
  engine.s 'protocol',
    sendAction: (turn, action) ->
      socket.emit 'action', action.serialize()
      return true
else 
  engine = EngineBuilder.build true # Single player local game acts as server
window.onload = () ->
  canvas = document.getElementById 'canvas'
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
  engine.s('render').canvas = canvas
  sendLast = new Date().getTime()
  prevTime = new Date().getTime()
  animationLoop = () ->
    window.requestAnimationFrame animationLoop
    # It has moved to setInterval now
  animationLoop()
  setInterval () ->
    newTime = new Date().getTime()
    engine.update newTime - prevTime
    prevTime = newTime
  , 16
  window.onresize = () ->
    canvas.width = window.innerWidth
    canvas.height = window.innerHeight
  window.onclick = () ->
    engine.aa 'controlSplit', null, engine.player
  window.addEventListener 'mousemove', (e) ->
    return if (new Date().getTime() - sendLast) < 100
    sendLast = new Date().getTime()
    rect = canvas.getBoundingClientRect()
    engine.aa 'playerMouse', null, engine.player,
      mouseX: e.clientX - rect.left - canvas.width / 2
      mouseY: e.clientY - rect.top - canvas.height / 2
  , false
  window.addEventListener 'touchmove', (e) ->
    return if (new Date().getTime() - sendLast) < 100
    sendLast = new Date().getTime()
    rect = canvas.getBoundingClientRect()
    engine.aa 'playerMouse', null, engine.player,
      mouseX: e.touches[0].pageX - rect.left - canvas.width / 2
      mouseY: e.touches[0].pageY - rect.top - canvas.height / 2
  , false
window.engine = engine
