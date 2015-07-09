define(['riot', 'app/RiotControl', 'action/ConnectionConstants', 'action/VertexConstants'],
function(riot, RiotControl) {

  var ConnectionActions = require('action/ConnectionConstants').actions;
  var VertexActions = require('action/VertexConstants').actions;

  function ConnectionStore() {
    var self = riot.observable(this)

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self)

    self.on(VertexActions.ADD_VERTEX, function() {
      console.log('from connstore ADD_VERTEX');
    });

    self.on(ConnectionActions.CONNECT, function(url) {
      console.log('connecting to', url);
      var ws = new WebSocket(url);
      ws.onopen = function() {
        self.trigger(ConnectionActions.CONNECTION_ESTABLISHED, ws);
      };
    });

  }

  return new ConnectionStore();
});
