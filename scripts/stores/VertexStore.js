define(['riot', 'action/VertexConstants', 'app/RiotControl'], function(riot, Actions, RiotControl) {
  function VertexStore() {
    var self = riot.observable(this)

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self)

    // DATA STORE
    self.vertices = []

    // Event listeners
    const EMIT_CHANGE = Actions.VERTEX_LIST_CHANGED
    self.on(Actions.GET_ALL, function() {
      self.trigger(EMIT_CHANGE, self.vertices)
    })

    self.on(Actions.ADD_VERTEX, function(vertex) {
      if (!vertex.id) {
        vertex.id = Math.random().toString(16).substr(2); // TODO: get the ID from GW
      }
      self.vertices.push(vertex)
      self.trigger(EMIT_CHANGE, self.vertices)
    })
  }

  return new VertexStore();
});
