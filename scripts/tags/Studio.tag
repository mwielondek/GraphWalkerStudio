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
  var VertexActions     = require('actions/VertexActions');
  var ElementConstants  = require('constants/ElementConstants');
  var ConnectionActions = require('actions/ConnectionActions');

  // STATE
  this.selection = [];
  this.model = undefined;

  // Handle passed in options
  this.on('mount', function() {
    if (opts.autoConnect && opts.autoConnect.enabled) {
      ConnectionActions.connect(opts.autoConnect.url);
    }
  });

  setModel(model) {
    // HACK: riot/#1003 workaround. Prevents vertex labels switching DOM nodes.
    this.model = {};
    this.update();

    this.model = model;
    this.selection = [];
    this.update();
  }

  // TODO: refactor using promises
  updateSelection(elements, type, toggle) {
    // If `elements` is falsy, clear selection
    if (!elements || elements.length == 0) {
      // If selection already is null prevent update.
      if (this.selection.length == 0) return;
      this.selection = [];
    } else {
      if (!Array.isArray(elements)) elements = [elements]; // Wrap single element into array

      if (toggle) {
        var _this = this;
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
        this.selection = elements.map(function(element) { return {id: element, type: type}});
      }

    }
    if (type !== ElementConstants.T_VERTEX) {
      this.update();
      return;
    }
    // Augment selection array with domIds
    var noDomId = this.selection.filter(function(el) { return !el.domId }).mapBy('id');
    var _this = this;
    VertexActions.getDomId(noDomId, function(domId) {
      _this.selection.forEach(function(el) {
        if (domId[el.id])
          el['domId'] = domId[el.id];
      });
      _this.update();
    });
  }

</studio>
