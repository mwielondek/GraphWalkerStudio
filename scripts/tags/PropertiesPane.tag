<properties-pane class="panecontainer">
  <h4>Properties</h4>
  <ul>
    <li>ID: { element.id }</li>
    <li><button onclick={ removeElement }>Remove { element.type }</button></li>
  </ul>

  var VertexActions    = require('actions/VertexActions');
  var EdgeActions      = require('actions/EdgeActions');
  var ElementConstants = require('constants/ElementConstants');

  var self = this;

  self.on('update', function() {
    self.element = opts.selection[0];
  });

  removeElement() {
    console.assert(opts.selection.length == 1, 'empty selection');
    // Call proper remove action
    switch (self.element.type) {
      case ElementConstants.T_VERTEX:
        VertexActions.remove(self.element.id);
        break;
      case ElementConstants.T_EDGE:
        EdgeActions.remove(self.element.id);
        break;
    }
  }
</properties-pane>
