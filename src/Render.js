var RenderSystem = {
  onAddedToEngine: function(engine) {
    this.engine = engine;
    this.entities = engine.e('pos', 'blob');
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
    this.ctx.strokeStyle = "black";
    this.ctx.fillStyle = "black";
    this.entities.forEach(function(entity) {
      var pos = entity.c('pos');
      //this.ctx.fillRect(pos.x + this.canvas.width / 2 - pos.radius, pos.y + this.canvas.height / 2 - pos.radius, 10, 10);
      if(this.ctx['arc']) {
        this.ctx.beginPath();
        this.ctx.arc(pos.x + this.canvas.width / 2 | 0, pos.y + this.canvas.height / 2 | 0, Math.abs(pos.radius) | 0, 0, Math.PI*2, false);
        this.ctx.stroke();
      } else {
        this.ctx.fillRect(this.canvas.width / 2 + (pos.x - pos.radius) * this.ratio * 2 | 0, this.canvas.height / 2 + (pos.y - pos.radius) * this.ratio | 0,
          pos.radius * 4 * this.ratio | 0, pos.radius * 2 * this.ratio | 0);
      }
    }, this);
    if(this.ctx.resetState) {
      this.ctx.resetState();
    }
  }
}

module.exports = RenderSystem;
