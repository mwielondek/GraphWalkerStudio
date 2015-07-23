<studio>
  <p>Studio</p>
  <studio-contextpane selection={ selection } />
  <studio-canvas options={ opts.canvas } selection={ selection } updateselection={ updateBuffer } />

  <style>
    studio {
      height: 90%;
      display: block;
    }
  </style>

  var VertexActions    = require('actions/VertexActions');
  var ElementConstants = require('constants/ElementConstants');

  // STATE
  this.selection = [];

  // Helper function for object arrays like `selection`
  Array.prototype.mapBy = function(prop) {
    return this.map(function(el) { return el[prop] });
  }

  // Pluralize known words
  String.prototype.pluralize = function(flag) {
    var WORDS = {
      'vertex' : 'vertices'
    };
    return flag ? WORDS[this] : this;
  }

  // Compare two arrays
  $.fn.isSameAs = function(compareTo) {
    var len = this.length;
    if (!compareTo || len != compareTo.length) return false;
    for (var i = 0; i < len; ++i) {
      if (this[i] !== compareTo[i]) return false;
    }
    return true;
  };

  // Buffers `updateSelection` calls and runs only the last one.
  // This is helpful when sometimes `updateSelection` gets called
  // many times due to various event handlers, but in the end we're
  // only interested in the last one.
  this.updateBuffer = (function(_this, timeout) {
    var _buffer = [];
    return function() {
      if (_buffer.length == 0) {
        setTimeout(function() {
          _this.updateSelection.apply(_this, _buffer);
          _buffer = [];
        }, timeout);
      }
      _buffer = arguments;
    }
  })(this, 180);


  // TODO: refactor using promises
  updateSelection(elements, type, toggle) {
    // If `elements` is falsy, clear selection
    if (!elements) {
      // If selection already is null prevent update.
      if (this.selection.length == 0) return;
      this.selection = [];
    } else {
      if (!Array.isArray(elements)) elements = [elements]; // Wrap single element into array

      if (toggle) {
        var _this = this;
        elements.forEach(function(element) {
          var index = _this.selection.map(function(el) { return el.id }).indexOf(element);
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
