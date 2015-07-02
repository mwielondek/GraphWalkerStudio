define(['riot', 'app/modelstore', 'app/canvas', 'tag/studioapp', 'app/riotcontrol'],
function(riot,   ModelStore,       Canvas) {
  var testVertices = [{label: 'test', view: {top: '100px', left: '100px'}}, {label: 'test2'},
  {label: 'test3', view: {top: '300px'}}];

  var modelStore = new ModelStore(testVertices);
  RiotControl.addStore(modelStore);

  var studioapp = riot.mount('studioapp');

  return {
    Canvas: Canvas,
    tag: studioapp
  }
});
