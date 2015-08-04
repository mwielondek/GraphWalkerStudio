<studio>
  <p>Studio</p>
  <studio-tabs tabs={ tabs } model={ model } />
  <studio-sidebar selection={ selection } model={ model } />
  <studio-canvas selection={ selection } model={ model } show={ tabs.length } />

  <style>
    studio {
      height: 90%;
      display: block;
    }
  </style>

  var jsp               = require('jsplumb');
  var RiotControl       = require('app/RiotControl');
  var ModelActions      = require('actions/ModelActions');
  var VertexActions     = require('actions/VertexActions');
  var StudioConstants   = require('constants/StudioConstants');
  var ConnectionActions = require('actions/ConnectionActions');

  var self = this;

  // STATE-HOLDING VARIABLES

  // SELECTION
  self.selection = [];
  Object.defineProperty(self, 'selection', { writable: false }); // Prevent from overwriting object
  self.selection.clear = function(preventUpdate) {
    this.constructor.prototype.clear.apply(this);
    if (!preventUpdate) self.update();
  };
  self.selection.update = function(elements, toggle) {
    // If `elements` is falsy, clear selection
    if (!elements || elements.length == 0) {

      // If selection already is null prevent update.
      if (this.length == 0) return;

      this.clear(true);
    } else {
      if (!Array.isArray(elements)) elements = [elements]; // Wrap single element into array

      if (toggle) {
        // If element isn't currently selected, add
        // it to selection otherwise deselect it.
        var _this = self;
        elements.forEach(function(element) {
          _this.selection.toggle(element);
        });
      } else {
        this.clear(true);
        this.push.apply(this, elements); // concatenates the array in place
      }

    }
    self.update();
  }.bind(self.selection);

  // TABS
  self.tabs = [];
  Object.defineProperty(self, 'tabs', { writable: false }); // Prevent from overwriting object
  self.tabs.open = function(model, preventUpdate) {
    if (!this.mapBy('id').contains(model.id)) {
      // Open existing model and set it as active
      this.push(model);
      if (!preventUpdate) self.update();
    }
  }.bind(self.tabs);
  self.tabs.close = function(modelId) {
    var index = this.mapBy('id').indexOf(modelId);

    // Change model selection if selected model is being removed
    if (self.model.id == modelId) {
      // Try selecting model immediately next to the left
      var next = index - 1;
      next = next < 0 ? 1 : next;
      self.model = this[next];
    }
    this.splice(index, 1);
    self.update();
  }.bind(self.tabs);

  // CURRENT MODEL
  var _modelHelperFunctions = self._model = {
    // Helper setter for calling from children
    set: function(model) {
      self.model = model;
    },
    // Create new model and set it as active
    new: function() {
      ModelActions.add({}, function(model) {
        self.model = model;
      });
    }
  };
  Object.defineProperty(self, 'model', {
    get: function() {
      return this._model;
    },
    set: function(model) {
      // HACK: riot/#1003 workaround. Prevents vertex labels switching DOM nodes.
      this._model = _modelHelperFunctions;
      this.update();

      if (model) {
        if (typeof model == 'string') {
          ModelActions.get(model, function(m) {
            self.model = m;
          });
          return;
        }

        this._model = $.extend({}, model, _modelHelperFunctions);
        self.tabs.open(model, true);
        this.selection.clear();

        // Restore pan position
        if (model.view && model.view.panzoom) {
          $('#canvas-body').panzoom('setMatrix', model.view.panzoom);
        } else {
          $('#canvas-body').panzoom('reset', { animate: false });
        }
      }
    }
  });

  // Handle passed in options
  self.on('mount', function() {
    if (opts.autoConnect && opts.autoConnect.enabled) {
      ConnectionActions.connect(opts.autoConnect.url);
    }
  });

  RiotControl.on(StudioConstants.calls.CLEAR_SELECTION, function() {
    self.selection.clear();
  });

</studio>
