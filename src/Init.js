// Entry point of the application

var EngineBuilder = require('./EngineBuilder');

if(typeof window === 'undefined') {
  console.log('server');
  // Server
  var engine = EngineBuilder.build(true);
  setInterval(function() {
    engine.update(100);
  }, 100);
  module.exports = engine;
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
