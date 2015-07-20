define(['app/RiotControl', 'constants/EdgeConstants', './ConnectionActions',
'jquery', 'constants/GWConstants'], function(RiotControl, Constants, connection, $) {

  var CALLS = Constants.calls;
  var EVENTS = Constants.events;
  var STATUS = Constants.status;
  var GW = require('constants/GWConstants').methods;

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
    removeForVertex: function(vertexId) {
      var _this = this;
      this.getAll(function(allEdges) {
        var edgesToRemove = allEdges.filter(function(el) {
          return el.sourceVertexId === vertexId || el.targetVertexId === vertexId });

        // TODO: instead refactor the store method to accept multiple edges...
        for (var i = 0; i < edgesToRemove.length; i++) {
          console.log('removing edge', edgesToRemove[i]);
          RiotControl.trigger(CALLS.REMOVE_EDGE, edgesToRemove[i]);
        }
      });
    }
  }
});
