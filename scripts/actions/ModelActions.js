define(['app/RiotControl', 'constants/ModelConstants', './GWActions',
'jquery', 'constants/GWConstants'], function(RiotControl, Constants, gwcon, $) {

  var CALLS       = Constants.calls;
  var EVENTS      = Constants.events;
  var GW          = require('constants/GWConstants').methods;

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
    add: function(newModel) {
      newModel = newModel || {};
      // Give vertex temporary ID if not already set
      if (!newModel.id) newModel.id = 'model' + String.fromCharCode(counter++);
      if (!newModel.name) newModel.name = newModel.id;
      RiotControl.trigger(CALLS.ADD_MODEL, newModel);

      // Prepare server request
      // var request = {
      //   command: GW.ADDMODEL
      // };
      // var _this = this;
      // gwcon.sendRequest(request,
      //   // On success
      //   function(response) {
      //     _this.setProps(newModel, {label: response.body.id, id: response.body.id, status: STATUS.VERIFIED});
      //   },
      //   // On error
      //   function(response) {
      //     _this.setProps(newModel, {id: response.body.id, status: STATUS.ERROR});
      //   }
      // );
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
