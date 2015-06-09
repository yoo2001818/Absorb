class RenderComponent
  constructor: ({@fill, @stroke}) ->
    color = Math.random() * 360
    @fill ?= "hsl(#{color}, 100%, 75%)"
    @stroke ?= "hsl(#{color}, 100%, 60%)"

class Camera
  constructor: (@x=0, @y=0, @ratio=1) ->

RenderSystem =
  priority: 10000
  add: (engine) ->
    @engine = engine
    @entities = engine.e 'pos', 'render'
    @canvas = null
    @ctx = null
    @camera = new Camera()
  update: (delta) -> 
    return if not @canvas
    @ctx = @canvas.getContext '2d' if not @ctx
    @ctx.lineWidth = 3
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    camX1 = @camera.x - @canvas.width / 2 / @camera.ratio | 0
    camY1 = @camera.y - @canvas.height / 2 / @camera.ratio | 0
    camX2 = @camera.x + @canvas.width / 2 / @camera.ratio | 0
    camY2 = @camera.y + @canvas.height / 2 / @camera.ratio | 0
    # TODO caching the circle for optimization, It'll draw some RAM though
    # TODO using two canvas can be helpful too
    for entity in @entities
      # Check if the entity is in the camera
      pos = entity.c 'pos'
      continue if camX1 > pos.x + pos.radius
      continue if camY1 > pos.y + pos.radius
      continue if camX2 < pos.x - pos.radius
      continue if camY2 < pos.y - pos.radius
      if entity.c('render').fill == 'none'
        @ctx.strokeStyle = entity.c('render').stroke
      else
        @ctx.fillStyle = entity.c('render').stroke
      @ctx.beginPath()
      @ctx.arc (-@camera.x + pos.x) * @camera.ratio + @canvas.width / 2, (-@camera.y + pos.y) * @camera.ratio + @canvas.height / 2,
        Math.abs(pos.radius * @camera.ratio), 0, Math.PI * 2, false
      if entity.c('render').fill == 'none'
        @ctx.stroke()
      else
        @ctx.fill()
    @ctx.textAlign = 'center'
    @ctx.textBaseline = 'middle'
    @ctx.lineWidth = 1
    for entity in @entities
      continue if entity.c('render').fill == 'none'
      pos = entity.c 'pos'
      continue if camX1 > pos.x + pos.radius
      continue if camY1 > pos.y + pos.radius
      continue if camX2 < pos.x - pos.radius
      continue if camY2 < pos.y - pos.radius
      @ctx.fillStyle = entity.c('render').fill
      @ctx.beginPath()
      @ctx.arc (-@camera.x + pos.x) * @camera.ratio + @canvas.width / 2, (-@camera.y + pos.y) * @camera.ratio + @canvas.height / 2,
        Math.abs(pos.radius * @camera.ratio - 3), 0, Math.PI * 2, false
      @ctx.fill()
      continue unless entity.c('control')
      continue unless entity.c('control').owner
      player = engine.e entity.c('control').owner
      continue unless player
      playerComp = player.c 'player'
      continue if pos.radius* @camera.ratio/2 < 15
      @ctx.font = (pos.radius* @camera.ratio/2)+"px sans-serif";
      @ctx.strokeStyle = '#000'
      @ctx.fillStyle = '#fff'
      @ctx.fillText playerComp.name, (-@camera.x + pos.x) * @camera.ratio + @canvas.width / 2, (-@camera.y + pos.y) * @camera.ratio + @canvas.height / 2
      @ctx.strokeText playerComp.name, (-@camera.x + pos.x) * @camera.ratio + @canvas.width / 2, (-@camera.y + pos.y) * @camera.ratio + @canvas.height / 2
    return

module.exports = 
  component: RenderComponent
  system: RenderSystem
  camera: Camera
