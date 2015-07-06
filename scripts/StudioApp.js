define(['riot', 'store/VertexStore', 'tag/Studio', 'app/RiotControl'],
function(riot,   VertexStore) {
  var testVertices = [{label: 'test', view: {centerY: 300, centerX: 200}},
  {label: 'test2'}, {label: 'test3', view: {centerY: 400}}];

  var vertexStore = new VertexStore(testVertices);
  RiotControl.addStore(vertexStore);

  var init = function(opts) {
    var opts = opts || {}
    return riot.mount('studio', opts);
  }

  return {
    init: init
  }
});
