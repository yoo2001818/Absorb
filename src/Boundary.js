function BoundaryComponent(args) {
}

var BoundarySystem = {
  onAddedToEngine: function(engine) {
    this.engine = engine;
    this.boundaries = engine.e('boundary', 'pos');
    this.entities = engine.e('blob', 'pos');
  },
  update: function(delta) {
    if(this.boundaries.length == 0) return;
    var boundary = this.boundaries[0].c('pos'); // Only 1st object is used; should be changed
    for(var i = 0; i < this.entities.length; ++i) {
      var entity = this.entities[i];
      var entityPos = entity.c('pos');
      var dist = entityPos.distance(boundary);
      var maxDist = boundary.radius - entityPos.radius;
      var diff = dist - maxDist;
      if(diff > 0) {
        var angle = Math.atan2(entityPos.y - boundary.y, entityPos.x - boundary.x);
        entityPos.x = Math.cos(angle) * maxDist + boundary.x;
        entityPos.y = Math.sin(angle) * maxDist + boundary.y;
        var vx = entity.c('blob').velX * Math.cos(angle) + entity.c('blob').velY * Math.sin(angle);
        var vy = entity.c('blob').velY * Math.cos(angle) - entity.c('blob').velX * Math.sin(angle);
        vx = -vx;
        entity.c('blob').velX = Math.cos(angle) * vx - Math.sin(angle) * vy;
        entity.c('blob').velY = Math.cos(angle) * vy + Math.sin(angle) * vx;
        // dasdasddd
       // entity.c('blob').velY *= -1;
      }
    }
  }
}

module.exports.component = BoundaryComponent;
module.exports.system = BoundarySystem;
