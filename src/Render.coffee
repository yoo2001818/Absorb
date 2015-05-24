class RenderComponent
  constructor: ({@fill, @stroke}) ->
    color = Math.random() * 360
    @fill ?= "hsl(#{color}, 100%, 75%)"
    @stroke ?= "hsl(#{color}, 100%, 60%)"

RenderSystem =
  priority: 10000
  onAddedToEngine: (engine) ->
    @engine = engine
    @entities = engine.e 'pos', 'render'
    @canvas = null
    @ctx = null
    @ratio = 1
  update: (delta) -> 
    return if not @canvas
    @ctx = @canvas.getContext '2d' if not @ctx
    @ctx.lineWidth = 3
    @ctx.fillStyle = "#fff"
    @ctx.fillRect 0, 0, @canvas.width, @canvas.height
    for entity in @entities
      if entity.c('render').fill == 'none'
        @ctx.strokeStyle = entity.c('render').stroke
      else
        @ctx.fillStyle = entity.c('render').stroke
      pos = entity.c 'pos'
      @ctx.beginPath()
      @ctx.arc pos.x * @ratio + @canvas.width / 2, pos.y * @ratio + @canvas.height / 2,
        Math.abs(pos.radius * @ratio), 0, Math.PI * 2, false
      if entity.c('render').fill == 'none'
        @ctx.stroke()
      else
        @ctx.fill()
    for entity in @entities
      continue if entity.c('render').fill == 'none'
      @ctx.fillStyle = entity.c('render').fill
      pos = entity.c 'pos'
      @ctx.beginPath()
      @ctx.arc pos.x * @ratio + @canvas.width / 2, pos.y * @ratio + @canvas.height / 2,
        Math.abs(pos.radius * @ratio - 3), 0, Math.PI * 2, false
      @ctx.fill()
    return

module.exports = 
  component: RenderComponent
  system: RenderSystem
