define(['app/RiotControl', 'constants/VertexConstants', './ConnectionActions',
'jquery', 'constants/GWConstants'], function(RiotControl, Constants, connection, $) {

  var CALLS = Constants.calls;
  var EVENTS = Constants.events;
  var STATUS = Constants.status;
  var GW = require('constants/GWConstants').methods;

  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(EVENTS.VERTEX_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function(callback) {
      RiotControl.trigger(CALLS.GET_ALL, callback);
    },
    addVertex: function(newVertex) {
      // give vertex temporary ID if not already set
      if (!newVertex.id) {
        newVertex.id = 'v_' + Math.random().toString(16).substr(2);
      }
      RiotControl.trigger(CALLS.ADD_VERTEX, newVertex);
      // Prepare message to server
      var request = JSON.stringify({
        type: GW.ADDVERTEX
      });
      connection.send(request);
      // Wait for relevant response
      var _this = this;
      connection.readUntil(function(message) {
        if (message.type == GW.ADDVERTEX) {
          if (message.success) {
            _this.setProps(newVertex, {id: message.id, status: STATUS.VERIFIED});
          } else {
            _this.setProps(newVertex, {id: message.id, status: STATUS.ERROR});
          }
          return true; // stop listening
        }
      });
    },
    setProps: function(query, props) {
      RiotControl.trigger(CALLS.CHANGE_VERTEX, query, props);
    }
  }
});
