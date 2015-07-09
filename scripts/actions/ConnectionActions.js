define(['app/RiotControl', './ConnectionConstants'], function(RiotControl, Constants) {

  var Actions = Constants.actions;

  return {
    // Listeners
    addConnectionListener: function(callback) {
      RiotControl.on(Actions.CONNECTION_ESTABLISHED, callback);
    },

    // Triggers
    getWebSocket: function() {
      RiotControl.trigger(Actions.GET_WEBSOCKET);
    },
    connect: function(url, callback) {
      RiotControl.trigger(Actions.CONNECT, url);
      this.addConnectionListener(callback);
    },
    send: function(message) {
      RiotControl.trigger(Actions.SEND, message);
    }
  }
});
