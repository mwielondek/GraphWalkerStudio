define(['riot', 'app/RiotControl', 'constants/ConnectionConstants', 'constants/VertexConstants'],
function(riot, RiotControl, Constants) {
  function ConnectionStore() {
    var self = riot.observable(this)

    var EVENTS = Constants.events;
    var CALLS = Constants.calls;

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
      // Data from the WebSocket comes in the form of a blob which needs
      // to be converted before use. Blob => JSON string => JSON object.
      self.reader = self.reader || new FileReader();

      var ws = new WebSocket(url);
      ws.onopen = function() {
        self.websocket = ws;
        self.trigger(EVENTS.CONNECTION_ESTABLISHED, ws);
      };
      ws.onclose = function() {
        self.trigger(EVENTS.CONNECTION_CLOSED);
      };
      ws.onmessage = function(evt) {
        var originalMessage = evt.data;
        self.reader.readAsText(originalMessage);
        self.reader.addEventListener('loadend', function handler() {
          var data   = self.reader.result;
          var dataObject = JSON.parse(data);
          self.trigger(EVENTS.INCOMING_MESSAGE, dataObject, originalMessage);
          self.reader.removeEventListener('loadend', handler);
        });
      };
    });

    self.on(CALLS.CLOSE, function() {
      if (self.websocket) self.websocket.close();
    });

  }

  return new ConnectionStore();
});
