// Entry point of the application

var EngineBuilder = require('./EngineBuilder');

if(typeof window === 'undefined') {
  console.log('server');
  // Server
  var engine = EngineBuilder.build(true);
  var Canvas = require('term-canvas');
  var canvas = new Canvas(50, 100);
  engine.s('render').canvas = canvas;
  setInterval(function() {
    engine.update(100);
  }, 100);
  module.exports = engine;
  process.on('SIGWINCH', function(){
    size = process.stdout.getWindowSize();
    canvas.width = size[0];
    canvas.height = size[1];
  });
  var size = process.stdout.getWindowSize();
  canvas.width = size[0];
  canvas.height = size[1];
} else {
  // Client
  var engine = EngineBuilder.build(false);
  window.onload = function() {
    engine.s('render').canvas = document.getElementById('canvas');
    engine.s('render').canvas.width = 640;
    engine.s('render').canvas.height = 480;
    function animationLoop() {
      window.requestAnimationFrame(animationLoop);
      engine.update(12);
    }
    animationLoop();
  }
  window.engine = engine;
}
