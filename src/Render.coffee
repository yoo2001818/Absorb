class RenderComponent
  constructor: ({@color}) ->
    @color ?= toRGB HSVtoRGB Math.random(), 1, 0.75

`
function HSVtoRGB(h, s, v) {
  var r, g, b, i, f, p, q, t;
  if (h && s === undefined && v === undefined) {
    s = h.s, v = h.v, h = h.h;
  }
  i = Math.floor(h * 6);
  f = h * 6 - i;
  p = v * (1 - s);
  q = v * (1 - f * s);
  t = v * (1 - (1 - f) * s);
  switch (i % 6) {
    case 0: r = v, g = t, b = p; break;
    case 1: r = q, g = v, b = p; break;
    case 2: r = p, g = v, b = t; break;
    case 3: r = p, g = q, b = v; break;
    case 4: r = t, g = p, b = v; break;
    case 5: r = v, g = p, b = q; break;
  }
  return {
    r: Math.floor(r * 255),
    g: Math.floor(g * 255),
    b: Math.floor(b * 255)
  };
}

function toRGB(color) {
  return (color.r << 16) | (color.g << 8) | (color.b);
}

function toColorString(color) {
  var r = (color >> 16) & 0xff;
  var g = (color >> 8) & 0xff;
  var b = (color) & 0xff;
  return 'rgb('+r+','+g+','+b+')';
}
`

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
      @ctx.fillStyle = toColorString entity.c('render').color
      pos = entity.c 'pos'
      @ctx.beginPath()
      @ctx.arc pos.x + @canvas.width / 2, pos.y + @canvas.height / 2,
        Math.abs(pos.radius), 0, Math.PI * 2, false
      @ctx.fill()
    return

module.exports = 
  component: RenderComponent
  system: RenderSystem
