function BlobComponent(args) {
  this.velX = args.velX || 0;
  this.velY = args.velY || 0;
}

var BlobSystem = {
  priority: 1500,
  onAddedToEngine: function(engine) {
    this.engine = engine;
    this.entities = engine.e('blob', 'pos');
  },
  update: function(delta) {
    for(var i = 0; i < this.entities.length; ++i) {
      var entity = this.entities[i];
      entity.c('pos').x += entity.c('blob').velX / 12 * delta;
      entity.c('pos').y += entity.c('blob').velY / 12 * delta;
      //entity.c('blob').velX *= Math.pow(0.994, 1 / 12 * delta);
      //entity.c('blob').velY *= Math.pow(0.994, 1 / 12 * delta);
      // TODO: Implement better algorithm of this, such as QuadTree
      for(var j = i+1; j < this.entities.length; ++j) {
        var other = this.entities[j];
        if(entity.c('pos').collides(other.c('pos'))) {
          // Bigger one eats smaller one
          var big, small;
          var bigPos, smallPos;
          if(entity.c('pos').radius > other.c('pos').radius) {
            big = entity;
            small = other;
          } else {
            big = other;
            small = entity;
          }
          bigPos = big.c('pos');
          smallPos = small.c('pos');
          var diff = bigPos.radius + smallPos.radius - bigPos.distance(smallPos);
          var weightGain =  smallPos.radius*smallPos.radius - 
            (smallPos.radius - diff) * (smallPos.radius - diff);
          var bigWeight = bigPos.radius*bigPos.radius + weightGain;
          bigPos.radius = Math.sqrt(bigWeight);
          smallPos.radius = smallPos.radius - diff;
          smallPos.radius = Math.max(0, smallPos.radius);
          big.c('blob').velX += small.c('blob').velX / bigWeight * weightGain;
          big.c('blob').velY += small.c('blob').velY / bigWeight * weightGain;
        }
      }
    }
    for(var i = 0; i < this.entities.length; ++i) {
      var entity = this.entities[i];
      if(entity.c('pos').radius <= 0) {
        this.engine.removeEntity(entity);
        i--
      }
    }
  }
}

module.exports.component = BlobComponent;
module.exports.system = BlobSystem;
