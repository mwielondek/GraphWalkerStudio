define(['riot', 'app/RiotControl', 'constants/ConnectionConstants', 'constants/VertexConstants'],
function(riot, RiotControl, Constants) {
  function ConnectionStore() {
    var self = riot.observable(this)

    var EVENTS = Constants.events;
    var CALLS  = Constants.calls;

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self)

    self.on(CALLS.GET_WEBSOCKET, function(callback) {
      callback(self.websocket);
    });

    self.on(CALLS.SEND, function(message) {
      if (self.websocket) self.websocket.send(message);
    });

    self.on(CALLS.CONNECT, function(url) {
      var ws = new WebSocket(url);
      ws.onopen = function() {
        self.websocket = ws;
        self.trigger(EVENTS.CONNECTION_ESTABLISHED, ws);
      };
      ws.onclose = function() {
        self.trigger(EVENTS.CONNECTION_CLOSED);
      };
      ws.onmessage = function(evt) {
        var dataObject = JSON.parse(evt.data);
        self.trigger(EVENTS.INCOMING_MESSAGE, dataObject);
      };
    });

    self.on(CALLS.CLOSE, function() {
      if (self.websocket) self.websocket.close();
    });

  }

  return new ConnectionStore();
});
