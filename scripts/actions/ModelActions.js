define(['app/RiotControl', 'constants/ModelConstants', './GWActions',
'jquery', 'constants/GWConstants', 'constants/StudioConstants'],
function(RiotControl, Constants, gwcon, $) {

  var CALLS  = Constants.calls;
  var EVENTS = Constants.events;
  var GW     = require('constants/GWConstants').methods;

  var StudioConstants = require('constants/StudioConstants');

  var counter = 65; // 'A'

  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(EVENTS.MODEL_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function(callback) {
      RiotControl.trigger(CALLS.GET_ALL, callback);
    },
    get: function(vertexId, callback) {
      RiotControl.trigger(CALLS.GET_MODEL, vertexId, callback);
    },
    add: function(newModel, callback) {
      newModel = newModel || {};
      // Give vertex temporary ID if not already set
      newModel.id = newModel.id || 'model' + String.fromCharCode(counter++);

      newModel.name = newModel.name || newModel.id;
      newModel.type = StudioConstants.types.T_MODEL;
      RiotControl.trigger(CALLS.ADD_MODEL, newModel);
      callback(newModel);

      // TODO send request to GW
    },
    setProps: function(query, props) {
      RiotControl.trigger(CALLS.CHANGE_MODEL, query, props);
    },
    remove: function(modelId) {
      RiotControl.trigger(CALLS.REMOVE_MODEL, modelId);

      // Remove all vertices which are part of the model
      // TODO
    },
  }
});
