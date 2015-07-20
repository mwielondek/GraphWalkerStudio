define(['riot', 'constants/VertexConstants', 'app/RiotControl', 'jquery'], function(riot, Constants, RiotControl, $) {
  function VertexStore() {
    var self = riot.observable(this);

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self);

    // DATA STORE
    self.vertices = [];

    // Event listeners
    var CALLS = Constants.calls;
    var EVENTS = Constants.events;
    const EMIT_CHANGE = EVENTS.VERTEX_LIST_CHANGED;
    self.on(CALLS.GET_ALL, function(callback) {
      callback(self.vertices)
    });

    self.on(CALLS.ADD_VERTEX, function(vertex) {
      self.vertices.push(vertex)
      self.trigger(EMIT_CHANGE, self.vertices)
    });

    self.on(CALLS.CHANGE_VERTEX, function(query, props) {
      var vertex = _getVertex(query);
      $.extend(true, vertex, props);
      self.trigger(EMIT_CHANGE, self.vertices);
    });

    self.on(CALLS.REMOVE_VERTEX, function(query) {
      var vertex = _getVertex(query);

      // Remove vertex from the array
      var index = self.vertices.indexOf(vertex);
      console.assert(index !== -1, 'Trying to remove a vertice that doesn\'t exist');
      self.vertices.splice(index, 1);
      self.trigger(EMIT_CHANGE, self.vertices);
    });

    // Helper functions

    // Get vertex either by object or by ID
    var _getVertex = function(query) {
      if (query !== null && typeof query === 'object') {
        // Extract id
        query = query.id;
      }
      // Search by ID
      return self.vertices.filter(function(el) { return el.id === query })[0];
    };
  }

  return new VertexStore();
});
