window.debug = (window.location.hostname == 'localhost' ? true : false)

// RequireJS config
var config = {
  baseUrl: 'lib',
  paths: {
    app:    '../scripts',
    actions: '../scripts/actions',
    constants: '../scripts/constants',
    store:  '../scripts/stores',
    tag:    '../scripts/tags/js'
  },
  map: {
    '*': { 'riot': 'riot_wip' } // DEV: use latest Riot version
  },
  shim: {
    // Merge all the tag shims into tag/Studio
    'tag/Studio': (function() {
      var tagShims = {
        'tag/Canvas': ['riot', 'jquery', 'app/RiotControl', 'actions/VertexActions', 'jsplumb'],
        'tag/Vertex': ['jquery', 'constants/VertexConstants', 'jsplumb'],
        'tag/ContextPane': ['actions/ConnectionActions'] // TODO: extract settings to own tag?
      };
      var compiledShim = [];
      for (var prop in tagShims) {
        if (tagShims[prop].constructor !== Array) continue;
        // Filter out duplicates and concatenate
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

  StudioApp.init();
});
