define(['app/RiotControl', 'constants/VertexConstants', './ConnectionActions',
'jquery', 'constants/GWConstants', './EdgeActions'], function(RiotControl, Constants, connection, $) {

  var CALLS       = Constants.calls;
  var EVENTS      = Constants.events;
  var STATUS      = Constants.status;
  var GW          = require('constants/GWConstants').methods;
  var EdgeActions = require('actions/EdgeActions');

  var counter = 65;

  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(EVENTS.VERTEX_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function(callback) {
      RiotControl.trigger(CALLS.GET_ALL, callback);
    },
    add: function(newVertex) {
      // give vertex temporary ID if not already set
      if (!newVertex.id) {
        newVertex.id = 'v_' + String.fromCharCode(counter++);//Math.random().toString(16).substr(2);
      }
      RiotControl.trigger(CALLS.ADD_VERTEX, newVertex);
      // TODO: refactor below into reusable method
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
    },
    remove: function(query) {
      // Remove edge tags
      EdgeActions.removeForVertex(query);
      RiotControl.trigger(CALLS.REMOVE_VERTEX, query)
      // // TODO: add GW connection request
    },

    // Helpers

    /**
     * Captures a series of actions and dispatches them all at a pre-set point in the future.
     * Remember to bind functions before calling bufferedAction if they rely on value of `this`.
     */
    bufferedAction: (function() {
      var _bufferedActionCache = [];
      var dispatch = function() {
        for (var i = 0, j = this.actions.length; i < j; i++) {
          this.actions[i]();
        }
      };
      return function(action, uniqueId, bufferUntil) {
        // Get buffered instance or create new one
        var bufferedAction = _bufferedActionCache.filter(function(el) { return el.id === uniqueId })[0];
        if (!bufferedAction) {
          bufferedAction = {
            id           : uniqueId,
            actions      : [],
            bufferUntil  : bufferUntil,
            bufferCounter: 0,
            dispatch     : dispatch
          };
          _bufferedActionCache.push(bufferedAction);
        }

        // Push the received action onto the action stack
        bufferedAction.actions.push(action);

        // Increment counter and check if we are ready to dispatch
        if (++bufferedAction.bufferCounter === bufferedAction.bufferUntil) {
          bufferedAction.dispatch();                                                   // Dispatch and
          _bufferedActionCache.splice(_bufferedActionCache.indexOf(bufferedAction),1); // remove instance
        }
      }
    })()
  }
});
