window.debug = true

// RequireJS config
var config = {
  baseUrl: 'lib',
  paths: {
    app: '../scripts',
    tag: '../scripts/tags/js'
  },
  shim: {
    'tag/vertex': ['jquery'],
    'tag/canvas': ['app/riotcontrol','jquery']
  }
};
// Prevent browser caching
if (window.debug) config.urlArgs = "bust=" +  (new Date()).getTime();
requirejs.config(config);

requirejs(['app/studioapp'], function(StudioApp) {
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
