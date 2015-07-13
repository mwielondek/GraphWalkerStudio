define(['app/RiotControl', 'constants/EdgeConstants', './ConnectionActions',
'jquery', 'constants/GWConstants'], function(RiotControl, Constants, connection, $) {

  var CALLS = Constants.calls;
  var EVENTS = Constants.events;
  var STATUS = Constants.status;
  var GW = require('constants/GWConstants').methods;

  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(EVENTS.EDGE_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function(callback) {
      RiotControl.trigger(CALLS.GET_ALL_EDGES, callback);
    },
    add: function(newEdge) {
      // give edge temporary ID if not already set
      if (!newEdge.id) {
        newEdge.id = 'v_' + Math.random().toString(16).substr(2);
      }
      RiotControl.trigger(CALLS.ADD_EDGE, newEdge);
      // // Prepare message to server
      // var request = JSON.stringify({
      //   type: GW.ADDEDGE
      // });
      // connection.send(request);
      // // Wait for relevant response
      // var _this = this;
      // connection.readUntil(function(message) {
      //   if (message.type == GW.ADDEDGE) {
      //     if (message.success) {
      //       _this.setProps(newEdge, {id: message.id, status: STATUS.VERIFIED});
      //     } else {
      //       _this.setProps(newEdge, {id: message.id, status: STATUS.ERROR});
      //     }
      //     return true; // stop listening
      //   }
      // });
    },
    setProps: function(query, props) {
      RiotControl.trigger(CALLS.CHANGE_EDGE, query, props);
    }
  }
});
