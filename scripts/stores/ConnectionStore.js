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

    self.on(ConnectionActions.GET_WEBSOCKET, function(callback) {
      // TODO: apply same getter instead of broadcast in VertexStore
      callback(self.websocket);
    });

    self.on(ConnectionActions.SEND, function(message) {
      self.websocket.send(message);
    });

    self.on(ConnectionActions.CONNECT, function(url) {
      console.log('connecting to', url);
      var ws = new WebSocket(url);
      ws.onopen = function() {
        self.websocket = ws;
        self.trigger(ConnectionActions.CONNECTION_ESTABLISHED, ws);
      };
      ws.onclose = function() {
        self.trigger(ConnectionActions.CONNECTION_CLOSED);
      };
      ws.onmessage = function(evt) {
        var message = evt.data
        self.trigger(ConnectionActions.INCOMING_MESSAGE, message);
      };
    });

    self.on(ConnectionActions.CLOSE, function() {
      if (self.websocket) self.websocket.close();
    });

  }

  return new ConnectionStore();
});
