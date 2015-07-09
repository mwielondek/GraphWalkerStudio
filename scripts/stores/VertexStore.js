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
      if (query !== null && typeof query === 'object') {
        // Search by object
        var vertex = self.vertices.filter(function(el) { return el === query })[0];
      } else if (typeof query === 'string') {
        // Search by ID
        var vertex = self.vertices.filter(function(el) { return el.id === query })[0];
      }
      $.extend(true, vertex, props);
      self.trigger(EMIT_CHANGE, self.vertices);
    })
  }

  return new VertexStore();
});
