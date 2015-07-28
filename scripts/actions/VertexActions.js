define(['app/RiotControl', 'constants/VertexConstants', './GWActions',
'jquery', 'constants/GWConstants', './EdgeActions'], function(RiotControl, Constants, gwcon, $) {

  var CALLS       = Constants.calls;
  var EVENTS      = Constants.events;
  var STATUS      = Constants.status;
  var GW          = require('constants/GWConstants').methods;
  var EdgeActions = require('actions/EdgeActions');

  var counter = 65; // 'A'

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
      // Give vertex temporary ID if not already set
      if (!newVertex.id) {
        newVertex.id = 'v_' + String.fromCharCode(counter++);
      }
      RiotControl.trigger(CALLS.ADD_VERTEX, newVertex);

      // Prepare server request
      var request = {
        command: GW.ADDVERTEX
      };
      var _this = this;
      gwcon.sendRequest(request,
        // On success
        function(response) {
          _this.setProps(newVertex, {label: response.body.id, id: response.body.id, status: STATUS.VERIFIED});
        },
        // On error
        function(response) {
          _this.setProps(newVertex, {id: response.body.id, status: STATUS.ERROR});
        }
      );
    },
    setProps: function(query, props) {
      RiotControl.trigger(CALLS.CHANGE_VERTEX, query, props);
    },
    remove: function(vertexIds) {
      if (!Array.isArray(vertexIds)) vertexIds = [vertexIds];
      RiotControl.trigger(CALLS.REMOVE_VERTEX, vertexIds, function() {
        EdgeActions.getForVertices(vertexIds, function(edgesToRemove) {
          EdgeActions.remove(edgesToRemove);
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
    }
  }
});
