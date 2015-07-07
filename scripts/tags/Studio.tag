<studio>
  <p>Studio</p>
  <studio-canvas options={ opts.canvas } selection={ selection } onselect={ onSelect } />


  // STATE
  this.context = '';
  this.selection = [];

  onSelect(vertex, append) {
    console.log('onselect', vertex, append);
    if (append) {
      this.selection.push(vertex);
    } else {
      this.selection = [vertex];
    }
    this.update();
  }

</studio>
