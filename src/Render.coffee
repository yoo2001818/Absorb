class RenderComponent
  constructor: ({@color}) ->
    @color ?= "hsl(#{Math.random()*360}, 100%, 75%)"

RenderSystem =
  priority: 10000
  onAddedToEngine: (engine) ->
    @engine = engine
    @entities = engine.e 'pos', 'render'
    @canvas = null
    @ctx = null
  update: (delta) -> 
    return if not @canvas
    @ctx = @canvas.getContext '2d' if not @ctx
    @ctx.clearRect 0, 0, @canvas.width, @canvas.height
    for entity in @entities
      @ctx.fillStyle = entity.c('render').color
      pos = entity.c 'pos'
      @ctx.beginPath()
      @ctx.arc pos.x + @canvas.width / 2, pos.y + @canvas.height / 2,
        Math.abs(pos.radius), 0, Math.PI * 2, false
      @ctx.fill()
    return

module.exports = 
  component: RenderComponent
  system: RenderSystem
