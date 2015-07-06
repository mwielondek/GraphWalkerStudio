define(['app/RiotControl', './VertexConstants'], function(RiotControl, Actions) {
  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(Actions.VERTEX_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function() {
      RiotControl.trigger(Actions.GET_ALL);
    },
    addVertex: function(newVertex) {
      RiotControl.trigger(Actions.ADD_VERTEX, newVertex);
    }
  }
});
