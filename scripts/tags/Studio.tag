<studio>
  <p>Studio</p>
  <studio-tabs tabs={ tabs } model={ model } setmodel={ setModel } />
  <studio-contextpane selection={ selection } model={ model } />
  <studio-canvas options={ opts.canvas } selection={ selection } model={ model } show={ model } />

  <style>
    studio {
      height: 90%;
      display: block;
    }
  </style>

  var jsp               = require('jsplumb');
  var RiotControl       = require('app/RiotControl');
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

  self.tabs = [];
  self.model = undefined;

  // Handle passed in options
  self.on('mount', function() {
    if (opts.autoConnect && opts.autoConnect.enabled) {
      ConnectionActions.connect(opts.autoConnect.url);
    }
  });

  RiotControl.on(StudioConstants.calls.CLEAR_SELECTION, function() {
    self.selection.clear(); // TODO: check if not better called directly from children
  });

  setModel(model) {
    // HACK: riot/#1003 workaround. Prevents vertex labels switching DOM nodes.
    self.model = undefined;
    self.update();

    if (model) {
      self.model = model;
      self.selection.clear();
    }
  }

</studio>
