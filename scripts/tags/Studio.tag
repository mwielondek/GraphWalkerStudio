<studio>
  <p>Studio</p>
  <studio-tabs tabs={ tabs } model={ model } />
  <studio-contextpane selection={ selection } model={ model } />
  <studio-canvas options={ opts.canvas } selection={ selection } model={ model } show={ tabs.length } />

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
    if (preventUpdate) {
      this.constructor.prototype.clear.apply(this);
    } else {
      this.constructor.prototype.clear.apply(this);
      self.update();
    }
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
  self.tabs.open = function(model) {
    if (model && !this.contains(model)) {
      // Open existing model and set it as active
      this.push(model);
      if (self.model != model) self.model = model;
      self.update();
    } else if(!model) {
      // Create new model
      var _this = this;
      ModelActions.add({}, function(model) {
        self.model = model;
      });
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
  Object.defineProperty(self, 'model', {
    get: function() {
      return this._model;
    },
    set: function(model) {
      // HACK: riot/#1003 workaround. Prevents vertex labels switching DOM nodes.
      this._model = { set: self._setModel };
      this.update();

      if (model) {
        this._model = model;
        this._model.set = self._setModel;
        this.selection.clear(true);
        self.tabs.open(model);
      }
    }
  });
  // Helper setter for calling from children
  _setModel(model) {
    self.model = model;
  }

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
