define(['app/RiotControl', 'constants/EdgeConstants', './ConnectionActions',
'jquery', 'jsplumb', 'constants/StudioConstants'],
function(RiotControl, Constants, connection, $) {

  var CALLS  = Constants.calls;
  var EVENTS = Constants.events;
  var STATUS = Constants.status;

  var StudioConstants = require('constants/StudioConstants');

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
      // Give edge temporary ID if not already set
      newEdge.id = newEdge.id || 'e_' + counter++;
      newEdge.name = newEdge.name || newEdge.id;

      newEdge.type = StudioConstants.types.T_EDGE;
      RiotControl.trigger(CALLS.ADD_EDGE, newEdge);
    },
    setProps: function(query, props) {
      RiotControl.trigger(CALLS.CHANGE_EDGE, query, props);
    },
    remove: function(edgeIds) {
      if (!Array.isArray(edgeIds)) edgeIds = [edgeIds];
      RiotControl.trigger(CALLS.REMOVE_EDGE, edgeIds);

      // Clear selection to refresh the properties pane
      RiotControl.trigger(StudioConstants.calls.CLEAR_SELECTION);
    },
    getForVertices: function(vertexIds, callback) {
      if (!Array.isArray(vertexIds)) vertexIds = [vertexIds];
      this.getAll(function(allEdges) {
        var results = [];
        vertexIds.forEach(function(vertexId) {
          var matchingEdges = allEdges.filter(function(el) {
            return el.sourceVertexId === vertexId || el.targetVertexId === vertexId;
          });
          results = results.concat(matchingEdges.filter(function(el) { return !results.contains(el) }));
        });
        callback(results);
      });
    }
  }
});
