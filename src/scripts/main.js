window.debug = (window.location.hostname == 'localhost' ? true : false)
window.debug.disableCache = false;


// Prevent browser caching
if (window.debug.disableCache) config.urlArgs = "bust=" +  (new Date()).getTime();
requirejs.config({
  baseUrl: 'lib',
  paths: {
    app      : '../scripts',
    actions  : '../scripts/actions',
    constants: '../scripts/constants',
    store    : '../scripts/stores',
    tag      : '../scripts/tags/js',
    tests    : '../scripts/tests',
    utils    : '../scripts/utils'
  }
});

requirejs(['app/StudioApp'], function(StudioApp) {
  if (window.debug) {
    window.StudioApp = StudioApp;
  } else {
    // disable log output if not in debug mode
    console.log = function() {};
  }

  StudioApp.init({
    autoConnect: {
      enabled: false,
      url: 'ws://localhost:9999'
    }
  });
});
