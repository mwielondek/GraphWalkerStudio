window.debug = true

// RequireJS config
var config = {
  baseUrl: 'lib',
  paths: {
    app: '../scripts',
    store: '../scripts/stores',
    tag: '../scripts/tags/js'
  },
  shim: {
    'tag/Studio': ['riot', 'jquery', 'app/RiotControl']
  }
};
// Prevent browser caching
if (window.debug) config.urlArgs = "bust=" +  (new Date()).getTime();
requirejs.config(config);

requirejs(['app/StudioApp'], function(StudioApp) {
  if (window.debug) {
    window.StudioApp = StudioApp;
  } else {
    // disable log output if not in debug mode
    console.log = function() {};
  }

  StudioApp.init({
    canvas: {
      bg: '#FF0000',
      vertex: {
        label: 'Custom name',
        view: {
          width: 200
        }
      }
    }
  });
  // StudioApp.init();
});
