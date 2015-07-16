window.debug = (window.location.hostname == 'localhost' ? true : false)

// RequireJS config
var config = {
  baseUrl: 'lib',
  paths: {
    app      : '../scripts',
    actions  : '../scripts/actions',
    constants: '../scripts/constants',
    store    : '../scripts/stores',
    tag      : '../scripts/tags/js'
  },
  map: {
    '*': {
      // 'riot': 'riot_wip', // DEV: use latest Riot version
      'jquery-ui': 'jquery-ui/jquery-ui'
    }
  },
  shim: {
    // Merge all the tag shims into tag/Studio
    'tag/Studio': (function() {
      var tagShims = {
        'tag/Canvas'        : ['riot', 'jquery', 'app/RiotControl', 'actions/VertexActions',
                               'actions/EdgeActions', 'jsplumb'],
        'tag/Vertex'        : ['riot', 'jquery', 'constants/VertexConstants', 'jsplumb', 'jquery-ui'],
        'tag/Edge'          : ['riot', 'jquery', 'constants/EdgeConstants', 'jsplumb'],
        'tag/ContextPane'   : ['riot'],
        'tag/PropertiesPane': ['riot', 'actions/VertexActions'],
        'tag/ConnectionPane': ['riot', 'actions/ConnectionActions']
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
