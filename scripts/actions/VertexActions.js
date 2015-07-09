define(['app/RiotControl', 'constants/VertexConstants'], function(RiotControl, Constants) {

  var CALLS = Constants.calls;
  var EVENTS = Constants.events;

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
      RiotControl.trigger(CALLS.ADD_VERTEX, newVertex);
    }
  }
});
