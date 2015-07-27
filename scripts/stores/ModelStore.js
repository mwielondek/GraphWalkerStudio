define(['riot', 'constants/ModelConstants', 'app/RiotControl', 'jquery', 'jsplumb', 'store/Utils'],
 function(riot, Constants, RiotControl, $) {

  var jsp   = require('jsplumb');
  var Utils = require('store/Utils');

  function ModelStore() {
    var self = riot.observable(this);

    // Register store with RiotControl. All subsequent `trigger` and `on` method calls through
    // RiotControl will be passed on to this store.
    RiotControl.addStore(self);

    // DATA STORE
    self.models = [];

    // Utils
    var _getModel = Utils.getElement.bind(undefined, self.models);

    // Event listeners
    var CALLS = Constants.calls;
    var EVENTS = Constants.events;
    const EMIT_CHANGE = EVENTS.MODEL_LIST_CHANGED;
    self.on(CALLS.GET_ALL, function(callback) {
      callback(self.models)
    });

    self.on(CALLS.GET_MODEL, function(modelId, callback) {
      callback(_getModel(modelId));
    });

    self.on(CALLS.ADD_MODEL, function(model) {
      self.models.push(model);
      self.trigger(EMIT_CHANGE, self.models);
    });

    self.on(CALLS.CHANGE_MODEL, function(query, props) {
      var model = _getModel(query);
      $.extend(true, model, props);
      self.trigger(EMIT_CHANGE, self.models);
    });

    self.on(CALLS.REMOVE_MODEL, function(query) {
      var model = _getModel(query);

      // Remove model from the array
      var index = self.models.indexOf(model);
      console.assert(index !== -1, 'Trying to remove a model that doesn\'t exist');
      self.models.splice(index, 1);
      self.trigger(EMIT_CHANGE, self.models);
    });

  }

  return new ModelStore();
});
