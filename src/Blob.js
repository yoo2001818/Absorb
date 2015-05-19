var Action = require('./engine/Action');

function BlobComponent(args) {
  this.velX = args.velX || 0;
  this.velY = args.velY || 0;
  this.parent = args.parent;
  this.radiusCap = args.radiusCap;
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
      entity.c('pos').x += entity.c('blob').velX / 1000 * delta;
      entity.c('pos').y += entity.c('blob').velY / 1000 * delta;
      entity.c('blob').velX *= Math.pow(0.994, 1 / 12 * delta);
      entity.c('blob').velY *= Math.pow(0.994, 1 / 12 * delta);
      // Find parent if available
      if(entity.c('blob').radiusCap) {
        entity.c('pos').radius += (entity.c('blob').radiusCap - entity.c('pos').radius) / 10;
        if(Math.abs(entity.c('pos').radius - entity.c('blob').radiusCap) < 1) {
          entity.c('pos').radius = entity.c('blob').radiusCap;
          entity.c('blob').radiusCap = null;
        }
      }
      if(entity.c('blob').radiusCap) continue;
      // TODO: Implement better algorithm of this, such as QuadTree
      for(var j = i+1; j < this.entities.length; ++j) {
        var other = this.entities[j];
        if(other.c('blob').radiusCap) continue;
        if(entity.c('blob').parent == other.id) {
          if(!entity.c('pos').collides(other.c('pos'))) {
           entity.c('blob').parent = null;
          }
          continue;
        }
        if(other.c('blob').parent == entity.id) {
          if(!entity.c('pos').collides(other.c('pos'))) {
            other.c('blob').parent = null;
          }
          continue;
        }
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

var BlobSplitAction = Action.scaffold(function(engine) {
  var radius = this.entity.c('pos').radius;
  var direction = Math.random() * Math.PI * 2;
  engine.e().c('pos', {
    x: this.entity.c('pos').x,
    y: this.entity.c('pos').y,
    radius: 1
  }).c('blob', {
    velX: Math.cos(direction) * radius * 3 + this.entity.c('blob').velX,
    velY: Math.sin(direction) * radius * 3+ this.entity.c('blob').velY,
    parent: this.entity.id,
    radiusCap: Math.sqrt(radius*radius/2)
  }).c('render', {
    color: this.entity.c('render').color
  });
  this.entity.c('blob').radiusCap = Math.sqrt(radius*radius/2);
  this.entity.c('blob').velX += Math.cos(direction) * -radius * 3;
  this.entity.c('blob').velY += Math.sin(direction) * -radius * 3
  ;
  this.result = 1;
});

module.exports.component = BlobComponent;
module.exports.system = BlobSystem;
module.exports.splitAction = BlobSplitAction;
