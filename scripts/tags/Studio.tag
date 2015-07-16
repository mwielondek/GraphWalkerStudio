<studio>
  <p>Studio</p>
  <studio-contextpane selection={ selection } />
  <studio-canvas options={ opts.canvas } selection={ selection } selectvertex={ updateSelection } />

  <style>
    studio {
      height: 90%;
      display: block;
    }
  </style>

  // STATE
  this.context = '';
  this.selection = [];

  updateSelection(vertices, toggle) {
    // If `vertices` is falsy, clear selection
    if (!vertices) {
      this.selection = [];
    } else {
      if (!Array.isArray(vertices)) vertices = [vertices];
      if (toggle) {
        var _this = this;
        vertices.forEach(function(vertex) {
          var index = _this.selection.indexOf(vertex);
          if (index == -1) {
            // If vertex isn't currently selected, add it to selection
            _this.selection.push(vertex);
          } else {
            // If vertex is currently selected, deselect it
            _this.selection.splice(index, 1);
          }
        });
      } else {
        this.selection = vertices;
      }
    }
    this.update();
  }

</studio>
