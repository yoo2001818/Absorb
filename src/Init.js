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
  var engine = EngineBuilder.build(true);
  window.onload = function() {
    engine.s('render').canvas = document.getElementById('canvas');
    engine.s('render').canvas.width = 640;
    engine.s('render').canvas.height = 480;
    var prevTime = new Date().getTime();
    function animationLoop() {
      window.requestAnimationFrame(animationLoop);
      engine.update((new Date().getTime()) - prevTime);
      prevTime = new Date().getTime();
    }
    animationLoop();
  }
  window.onclick = function() {
    engine.e('blob', 'pos').forEach(function(entity) {
      if(entity.c('pos').radius > 20) {
        engine.aa('blobSplit', null, entity);
      }
    });
  }
  window.engine = engine;
}
