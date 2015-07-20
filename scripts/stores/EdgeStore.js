define(['riot', 'constants/EdgeConstants', 'app/RiotControl', 'jquery'], function(riot, Constants, RiotControl, $) {
  function EdgeStore() {
    var self = riot.observable(this);

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self);

    // DATA STORE
    self.edges = [];

    // Event listeners
    var CALLS = Constants.calls;
    var EVENTS = Constants.events;
    const EMIT_CHANGE = EVENTS.EDGE_LIST_CHANGED;
    self.on(CALLS.GET_ALL_EDGES, function(callback) {
      callback(self.edges)
    });

    self.on(CALLS.ADD_EDGE, function(edge) {
      self.edges.push(edge)
      self.trigger(EMIT_CHANGE, self.edges)
    });

    self.on(CALLS.CHANGE_EDGE, function(query, props) {
      if (query !== null && typeof query === 'object') {
        // Search by object
        var edge = self.edges.filter(function(el) { return el === query })[0];
      } else if (typeof query === 'string') {
        // Search by ID
        var edge = self.edges.filter(function(el) { return el.id === query })[0];
      }
      $.extend(true, edge, props);
      self.trigger(EMIT_CHANGE, self.edges);
    });

    self.on(CALLS.REMOVE_EDGE, function(query) {
      if (query !== null && typeof query === 'object') {
        // Search by object
        var edge = self.edges.filter(function(el) { return el === query })[0];
      } else if (typeof query === 'string') {
        // Search by ID
        var edge = self.edges.filter(function(el) { return el.id === query })[0];
      }
      self.edges.splice(self.edges.indexOf(edge),1);
      self.trigger(EMIT_CHANGE, self.edges);
    });
  }

  return new EdgeStore();
});
