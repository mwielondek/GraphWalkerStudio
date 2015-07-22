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
    get: function(vertexId, callback) {
      RiotControl.trigger(CALLS.GET_VERTEX, vertexId, callback);
    },
    add: function(newVertex) {
      // give vertex temporary ID if not already set
      if (!newVertex.id) {
        newVertex.id = 'v_' + String.fromCharCode(counter++);
      }
      RiotControl.trigger(CALLS.ADD_VERTEX, newVertex);
      // TODO: refactor below into reusable method
      // Prepare message to server
      var request = {
        command: GW.ADDVERTEX
      };
      connection.sendRequest(request);
      // Wait for relevant response
      var _this = this;
      connection.readUntil(function(message) {
        if (message.command == GW.ADDVERTEX) {
          if (message.success) {
            _this.setProps(newVertex, {label: message.id, id: message.id, status: STATUS.VERIFIED});
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
    remove: function(vertexIds) {
      if (!Array.isArray(vertexIds)) vertexIds = [vertexIds];
      this.getDomId(vertexIds, function(domId) {
        vertexIds.forEach(function(vertexId) {
          var vertexDomId = domId[vertexId];
          // Remove edge tags
          EdgeActions.removeForVertex(vertexDomId);
          RiotControl.trigger(CALLS.REMOVE_VERTEX, vertexId)
        });
      });
      // TODO: add GW connection request
    },
    getDomId: function(idArray, callback) {
      if (!idArray || idArray.length == 0) {
        callback([]);
        return;
      };
      if (!Array.isArray(idArray)) idArray = [idArray];
      // TODO instead of using a counter, use promises
      var DomIdDictionary = {_counter: 0};
      var _this = this;
      idArray.forEach(function(el) {
        _this.get(el, function(vertex) {
          console.assert(vertex, 'Couldn\'t fetch vertex for id', el);
          DomIdDictionary[el] = vertex.view.domId;
          if (++DomIdDictionary._counter == idArray.length) callback(DomIdDictionary);
        });
      });
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
