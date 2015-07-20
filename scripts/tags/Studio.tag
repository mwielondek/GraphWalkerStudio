<studio>
  <p>Studio</p>
  <studio-contextpane selection={ selection } />
  <studio-canvas options={ opts.canvas } selection={ selection } updateselection={ updateSelection } />

  <style>
    studio {
      height: 90%;
      display: block;
    }
  </style>

  // STATE
  this.selection = [];

  // Helper function for object arrays like `selection`
  Array.prototype.mapBy = function(prop) {
    return this.map(function(el) { return el[prop] });
  }

  updateSelection(elements, type, toggle) {
    // If `elements` is falsy, clear selection
    if (!elements) {
      this.selection = [];
    } else {
      if (!Array.isArray(elements)) elements = [elements];
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
    this.update();
  }

</studio>
