function PositionComponent(args) {
  this.x = args.x;
  this.y = args.y;
  this.radius = args.radius || 4;
}

PositionComponent.prototype.distance = function(other) {
  var xDiff = this.x - other.x;
  var yDiff = this.y - other.y;
  return Math.sqrt(xDiff * xDiff + yDiff * yDiff);
}

PositionComponent.prototype.collides = function(other) {
  return this.distance(other) < (this.radius + other.radius);
}

module.exports = PositionComponent;
