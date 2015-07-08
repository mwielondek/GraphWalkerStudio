<studio>
  <p>Studio</p>
  <studio-contextpane selection={ selection } />
  <studio-canvas options={ opts.canvas } selection={ selection } onselect={ updateSelection } />

  <style>
    studio {
      height: 90%;
      display: block;
    }
  </style>

  // STATE
  this.context = '';
  this.selection = [];

  updateSelection(vertex, toggle) {
    // If vertex is falsy, clear selection
    if (!vertex) {
      this.selection = [];
    } else {
      if (toggle) {
        var index = this.selection.indexOf(vertex);
        if (index == -1) {
          // If vertex isn't currently selected, add it to selection
          this.selection.push(vertex);
        } else {
          // If vertex is currently selected, deselect it
          this.selection.splice(index, 1);
        }
      } else {
        this.selection = [vertex];
      }
    }
    this.update();
  }

</studio>
