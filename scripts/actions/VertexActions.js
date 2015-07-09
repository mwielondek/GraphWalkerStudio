define(['app/RiotControl', 'constants/VertexConstants'], function(RiotControl, Constants) {

  var Actions = Constants.actions;

  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(Actions.VERTEX_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function(callback) {
      RiotControl.trigger(Actions.GET_ALL, callback);
    },
    addVertex: function(newVertex) {
      RiotControl.trigger(Actions.ADD_VERTEX, newVertex);
    }
  }
});
