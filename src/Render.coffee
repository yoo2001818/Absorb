class RenderComponent
  constructor: ({@color}) ->
    @color ?= Math.random()*360

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
    @ctx.fillStyle = "#fff";
    @ctx.fillRect 0, 0, @canvas.width, @canvas.height
    for entity in @entities
      @ctx.fillStyle = "hsl(#{entity.c('render').color}, 100%, 60%)"
      pos = entity.c 'pos'
      @ctx.beginPath()
      @ctx.arc pos.x * @ratio + @canvas.width / 2, pos.y * @ratio + @canvas.height / 2,
        Math.abs(pos.radius * @ratio), 0, Math.PI * 2, false
      @ctx.fill()
    for entity in @entities
      @ctx.fillStyle = "hsl(#{entity.c('render').color}, 100%, 75%)"
      pos = entity.c 'pos'
      @ctx.beginPath()
      @ctx.arc pos.x * @ratio + @canvas.width / 2, pos.y * @ratio + @canvas.height / 2,
        Math.abs(pos.radius * @ratio - 3), 0, Math.PI * 2, false
      @ctx.fill()
    return

module.exports = 
  component: RenderComponent
  system: RenderSystem
