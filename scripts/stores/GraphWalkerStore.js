define(['riot', 'app/RiotControl', 'constants/GraphWalkerConstants', 'actions/GraphWalkerActions',
'constants/VertexConstants', 'constants/EdgeConstants'],
function(riot, RiotControl, Constants, Actions) {

  var VertexConstants = require('constants/VertexConstants');
  var EdgeConstants   = require('constants/EdgeConstants');

  function GraphWalkerStore() {
    var self = riot.observable(this);

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self);

    // Event listeners
    var VCALLS   = VertexConstants.calls;
    var METHODS = Constants.methods;

    // React to VertexStore events
    self.on(VCALLS.ADD_VERTEX, function(vertex) {
      Actions.addVertex(vertex);
    });

    self.on(VCALLS.CHANGE_VERTEX, function(query, props) {
      // Determine whether the change should be verified with GW
      if (props.name) Actions.changeVertex(query, props);
    });

    self.on(VCALLS.REMOVE_VERTEX, function(vertices) {
      vertices.forEach(Actions.removeVertex);
    });

    // TODO: React to EdgeStore events
    // TODO: React to ModelStore events

  }

  return new GraphWalkerStore();
});
