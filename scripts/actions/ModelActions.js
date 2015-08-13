define(['app/RiotControl', 'constants/ModelConstants',
'jquery', 'constants/StudioConstants', './VertexActions'],
function() {
  'use strict';

  var $               = require('jquery');
  var Constants       = require('constants/ModelConstants');
  var RiotControl     = require('app/RiotControl');
  var VertexActions   = require('actions/VertexActions');
  var StudioConstants = require('constants/StudioConstants');

  var CALLS  = Constants.calls;
  var EVENTS = Constants.events;


  var counter = 65; // 'A'

  return {
    // Listeners
    addChangeListener: function(callback) {
      RiotControl.on(EVENTS.MODEL_LIST_CHANGED, callback);
    },

    // Triggers
    getAll: function(callback) {
      RiotControl.trigger(CALLS.GET_ALL_MODELS, callback);
    },
    get: function(modelId, callback) {
      RiotControl.trigger(CALLS.GET_MODEL, modelId, callback);
    },
    add: function(newModel, callback) {
      newModel = newModel || {};
      // Give vertex temporary ID if not already set
      newModel.id = newModel.id || 'model' + String.fromCharCode(counter++);

      newModel.name = newModel.name || newModel.id;
      newModel.type = StudioConstants.types.T_MODEL;
      RiotControl.trigger(CALLS.ADD_MODEL, newModel);
      callback(newModel);
    },
    setProps: function(query, props) {
      RiotControl.trigger(CALLS.CHANGE_MODEL, query, props);
    },
    remove: function(modelId) {
      RiotControl.trigger(CALLS.REMOVE_MODEL, modelId);

      // Remove all vertices which are part of the model
      VertexActions.getAll(function(vertices) {
        VertexActions.remove(vertices.filter(function(el) {
          return el.modelId === modelId;
        }));
      })
    },
  }
});
