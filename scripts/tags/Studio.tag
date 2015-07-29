<studio>
  <p>Studio</p>
  <studio-tabs model={ model } setmodel={ setModel } />
  <studio-contextpane selection={ selection } model={ model } />
  <studio-canvas options={ opts.canvas } selection={ selection } updateselection={ updateSelection }
    model={ model } show={ model } />

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

  // STATE
  self.selection = [];
  self.model = undefined;

  // Handle passed in options
  self.on('mount', function() {
    if (opts.autoConnect && opts.autoConnect.enabled) {
      ConnectionActions.connect(opts.autoConnect.url);
    }
  });

  RiotControl.on(StudioConstants.calls.CLEAR_SELECTION, function() {
    self.updateSelection(0);
  });

  setModel(model) {
    // HACK: riot/#1003 workaround. Prevents vertex labels switching DOM nodes.
    self.model = undefined;
    self.update();

    if (model) {
      self.model = model;
      self.selection = [];
      self.update();
    }
  }

  // TODO: refactor using promises
  updateSelection(elements, type, toggle) {
    // If `elements` is falsy, clear selection
    if (!elements || elements.length == 0) {
      // If selection already is null prevent update.
      if (self.selection.length == 0) return;
      self.selection = [];
    } else {
      if (!Array.isArray(elements)) elements = [elements]; // Wrap single element into array

      if (toggle) {
        var _this = self;
        elements.forEach(function(element) {
          var index = _this.selection.mapBy('id').indexOf(element);
          if (index == -1) {
            // If element isn't currently selected, add it to selection
            _this.selection.push({id: element, type: type});
          } else {
            // If element is currently selected, deselect it
            _this.selection.splice(index, 1);
          }
        });
      } else {
        self.selection = elements.map(function(element) { return {id: element, type: type}});
      }

    }
    if (type == StudioConstants.types.T_VERTEX) {
      // Augment vertex selection array with domIds
      var noDomId = self.selection.filter(function(el) { return !el.domId }).mapBy('id');
      var _this = self;
      VertexActions.getDomId(noDomId, function(domId) {
        _this.selection.forEach(function(el) {
          if (domId[el.id])
          el['domId'] = domId[el.id];
        });
        _this.update();
      });
    } else {
      self.update();
    }
  }

</studio>
