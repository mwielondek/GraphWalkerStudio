<studio>
  <p>Studio</p>
  <studio-canvas options={ opts.canvas } selection={ selection } onselect={ updateSelection } />


  // STATE
  this.context = '';
  this.selection = [];

  updateSelection(vertex, append) {
    // If vertex is falsy, clear selection
    if (!vertex) {
      this.selection = [];
    } else {
      if (append && this.selection.indexOf(vertex) < 0) {
        // Append to existing selection if append flag is set and not already selected
        this.selection.push(vertex);
      } else {
        this.selection = [vertex];
      }
    }
    this.update();
  }

</studio>
