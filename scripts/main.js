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
    // merge all the tag shims into tag/Studio
    'tag/Studio': (function() {
      var tagShims = {
        'tag/Canvas': ['riot', 'jquery', 'app/RiotControl', 'action/VertexConstants'],
        'tag/Vertex': ['jquery']
      };
      var compiledShim = [];
      for (var prop in tagShims) {
        if (tagShims[prop].constructor !== Array) continue;
        compiledShim = compiledShim.concat(tagShims[prop].filter(
          function(el) { return compiledShim.indexOf(el) == -1 }));
      }
      return compiledShim;
    })()
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
