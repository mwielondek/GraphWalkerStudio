<properties-pane class="panecontainer">
  <h4>Properties</h4>
  <ul>
    <li if={!isMultipleSelection}>ID: { element.id }</li>
    <li if={isMultipleSelection}>Selected { opts.selection.length } {element.type.pluralize(isMultipleSelection)}</li>
    <li><button onclick={ removeElement }>Remove { element.type.pluralize(isMultipleSelection) }</button></li>
  </ul>

  var VertexActions    = require('actions/VertexActions');
  var EdgeActions      = require('actions/EdgeActions');
  var ElementConstants = require('constants/ElementConstants');

  var self = this;

  self.on('update', function() {
    self.element = opts.selection[0];
    self.isMultipleSelection = opts.selection.length > 1;
  });

  removeElement() {
    console.assert(opts.selection.length > 0, 'empty selection');
    // Call proper remove action
    switch (self.element.type) {
      case ElementConstants.T_VERTEX:
        VertexActions.remove(opts.selection.mapBy('id'));
        break;
      case ElementConstants.T_EDGE:
        EdgeActions.remove(self.element.id);
        break;
    }
  }
</properties-pane>
