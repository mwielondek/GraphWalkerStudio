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
    'tag/canvas': ['app/riotcontrol']
  }
};
// Prevent browser caching
if (window.debug) config.urlArgs = "bust=" +  (new Date()).getTime();
requirejs.config(config);

requirejs(['app/studioapp'], function(StudioApp) {
  // disable log output if not in debug mode
  if (!window.debug) console.log = function() {}
});
