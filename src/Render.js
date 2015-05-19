function RenderComponent(args) {
  this.color = args.color || toRGB(HSVtoRGB(Math.random(), Math.random()*0.5+0.5, Math.random()*0.5+0.5));
}

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

var RenderSystem = {
  priority: 10000,
  onAddedToEngine: function(engine) {
    this.engine = engine;
    this.entities = engine.e('pos', 'render');
    this.canvas = null;
    this.ctx = null;
    this.ratio = 24/240;
  },
  update: function(delta) {
    if(!this.canvas) return;
    if(!this.ctx) {
      this.ctx = this.canvas.getContext('2d');
    }
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.fillStyle = "black";
    this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
    this.ctx.strokeStyle = "black";
    this.entities.forEach(function(entity) {
      this.ctx.fillStyle = toColorString(entity.c('render').color);
      var pos = entity.c('pos');
      //this.ctx.fillRect(pos.x + this.canvas.width / 2 - pos.radius, pos.y + this.canvas.height / 2 - pos.radius, 10, 10);
      this.ctx.beginPath();
      //this.ctx.rect(pos.x + this.canvas.width / 2 - pos.radius, pos.y + this.canvas.height / 2 - pos.radius, pos.radius * 2, pos.radius * 2);
      this.ctx.arc(pos.x + this.canvas.width / 2, pos.y + this.canvas.height / 2, Math.abs(pos.radius), 0, Math.PI*2, false);
      this.ctx.fill();
    }, this);
  }
}

module.exports.component = RenderComponent;
module.exports.system = RenderSystem;