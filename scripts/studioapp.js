define(['riot', 'app/modelstore', 'app/canvas', 'tag/studioapp', 'app/riotcontrol'],
function(riot,   ModelStore,       Canvas) {
  var testVertices = [{label: 'test', view: {centerY: 300, centerX: 200}},
  {label: 'test2'}, {label: 'test3', view: {centerY: 400}}];

  var modelStore = new ModelStore(testVertices);
  RiotControl.addStore(modelStore);

  var init = function(opts) {
    var opts = opts || {}
    return riot.mount('studioapp', opts);
  }

  return {
    Canvas: Canvas,
    init: init
  }
});
