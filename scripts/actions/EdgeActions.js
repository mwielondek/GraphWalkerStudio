define(['app/RiotControl', 'constants/EdgeConstants', './ConnectionActions',
'jquery', 'constants/GWConstants', 'jsplumb'],
function(RiotControl, Constants, connection, $) {

  var CALLS  = Constants.calls;
  var EVENTS = Constants.events;
  var STATUS = Constants.status;
  var GW     = require('constants/GWConstants').methods;

  var jsp = require('jsplumb');

  var counter = 1;

  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(EVENTS.EDGE_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function(callback) {
      RiotControl.trigger(CALLS.GET_ALL_EDGES, callback);
    },
    getById: function(edgeId, callback) {
      RiotControl.trigger(CALLS.GET_EDGE, edgeId, function(edge) {
        callback(edge);
      });
    },
    add: function(newEdge) {
      // give edge temporary ID if not already set
      if (!newEdge.id) {
        newEdge.id = 'e_' + counter++;//Math.random().toString(16).substr(2);
      }
      RiotControl.trigger(CALLS.ADD_EDGE, newEdge);
      // TODO: Sent request to GW
    },
    setProps: function(query, props) {
      RiotControl.trigger(CALLS.CHANGE_EDGE, query, props);
    },
    remove: function(edgeId) {
      var connection = this.getById(edgeId, function(edge) {
        var connection = edge._jsp_connection;
        jsp.detach(connection);
      });
      RiotControl.trigger(CALLS.REMOVE_EDGE, edgeId);
    },
    removeForVertex: function(vertexDomId) {
      var _this = this;
      this.getAll(function(allEdges) {
        var edgesToRemove = allEdges.filter(function(el) {
          return el.sourceVertexId === vertexDomId || el.targetVertexId === vertexDomId;
        });

        // TODO: instead refactor the store method to accept multiple edges...
        for (var i = 0; i < edgesToRemove.length; i++) {
          _this.remove(edgesToRemove[i].id);
        }
      });
    }
  }
});
