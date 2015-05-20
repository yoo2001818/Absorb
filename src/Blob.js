var Action = require('./engine/Action');

function BlobComponent(args) {
  this.velX = args.velX || 0;
  this.velY = args.velY || 0;
  this.parent = args.parent;
  this.weight = args.weight || 0.15;
  this.weightCap = args.weightCap;
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
      entity.c('blob').velX *= Math.pow(0.994, 1 / 32 * delta);
      entity.c('blob').velY *= Math.pow(0.994, 1 / 32 * delta);
      entity.c('pos').radius = Math.sqrt(entity.c('blob').weight);
      // Find parent if available
      if(entity.c('blob').weightCap) {
        entity.c('blob').weight += (entity.c('blob').weightCap - entity.c('blob').weight) / 4;
        if(Math.abs(entity.c('blob').weight - entity.c('blob').weightCap) < 1) {
          entity.c('blob').weight = entity.c('blob').weightCap;
          entity.c('blob').weightCap = null;
        }
      }
      if(entity.c('blob').weightCap) continue;
      // TODO: Implement better algorithm of this, such as QuadTree
      for(var j = i+1; j < this.entities.length; ++j) {
        var other = this.entities[j];
        if(other.c('blob').weightCap) continue;
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
          var weightGain = Math.min(small.c('blob').weight, Math.max(0, small.c('blob').weight - 
            (smallPos.radius - diff) * (smallPos.radius - diff)));
          if(small.c('blob').weight-weightGain > 10) {
            weightGain = small.c('blob').weight; 
          } 
          big.c('blob').weight += weightGain;
          bigPos.radius = Math.sqrt(big.c('blob').weight);
          small.c('blob').weight -= weightGain;
          small.c('blob').weight = Math.max(0, small.c('blob').weight);
          smallPos.radius = Math.sqrt(small.c('blob').weight);
          big.c('blob').velX += small.c('blob').velX / big.c('blob').weight * weightGain;
          big.c('blob').velY += small.c('blob').velY / big.c('blob').weight * weightGain;
        }
      }
    }
    for(var i = 0; i < this.entities.length; ++i) {
      var entity = this.entities[i];
      if(entity.c('blob').weight <= 0.1) {
        this.engine.removeEntity(entity);
        i--
      }
    }
  }
}

var BlobSplitAction = Action.scaffold(function(engine) {
  var weight = this.entity.c('blob').weight / 2;
  var direction = Math.random() * Math.PI * 2;
  engine.e().c('pos', {
    x: this.entity.c('pos').x,
    y: this.entity.c('pos').y,
    radius: 1
  }).c('blob', {
    velX: Math.cos(direction) * Math.sqrt(weight) * 3 + this.entity.c('blob').velX,
    velY: Math.sin(direction) * Math.sqrt(weight) * 3 + this.entity.c('blob').velY,
    parent: this.entity.id,
    weightCap: weight,
    weight: 1
  }).c('render', {
    color: this.entity.c('render').color
  });
  this.entity.c('blob').weightCap = weight;
  this.entity.c('blob').velX += Math.cos(direction) * -Math.sqrt(weight) * 3;
  this.entity.c('blob').velY += Math.sin(direction) * -Math.sqrt(weight) * 3
  ;
  this.result = 1;
});

module.exports.component = BlobComponent;
module.exports.system = BlobSystem;
module.exports.splitAction = BlobSplitAction;
