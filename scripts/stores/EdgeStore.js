define(['riot', 'constants/EdgeConstants', 'app/RiotControl', 'jquery', 'store/Utils'],
function(riot, Constants, RiotControl, $, Utils) {
  function EdgeStore() {
    var self = riot.observable(this);

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self);

    // DATA STORE
    self.edges = [];

    // Utils
    var _getEdge = Utils.getElement.bind(undefined, self.edges);

    // Event listeners
    var CALLS = Constants.calls;
    var EVENTS = Constants.events;
    const EMIT_CHANGE = EVENTS.EDGE_LIST_CHANGED;
    self.on(CALLS.GET_ALL_EDGES, function(callback) {
      callback(self.edges)
    });

    self.on(CALLS.GET_EDGE, function(edgeId, callback) {
      callback(self.edges.filter(function(el) { return el.id === edgeId})[0]);
    });

    self.on(CALLS.ADD_EDGE, function(edge) {
      self.edges.push(edge)
      self.trigger(EMIT_CHANGE, self.edges)
    });

    self.on(CALLS.CHANGE_EDGE, function(query, props) {
      var edge = _getEdge(query);
      $.extend(true, edge, props);
    });

    self.on(CALLS.REMOVE_EDGE, function(edges) {
      edges.forEach(function(el) {
        var edge = _getEdge(el);
        self.edges.splice(self.edges.indexOf(edge), 1);
      });

      // HACK: riot/#1003 workaround.
      self.trigger(EMIT_CHANGE, []);
      self.trigger(EMIT_CHANGE, self.edges);
    });

  }

  return new EdgeStore();
});
