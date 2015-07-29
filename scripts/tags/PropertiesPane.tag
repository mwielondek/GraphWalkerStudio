<properties-pane class="panecontainer">
  <h4>Properties</h4>
  <ul>
    <li if={!isMultipleSelection}>ID: { element.id }</li>
    <li if={isMultipleSelection}>
      Selected { opts.selection.length } {element.type.pluralize(isMultipleSelection)}
    </li>
    <li><button onclick={ removeElement }>Remove { element.type.pluralize(isMultipleSelection) }</button></li>
  </ul>

  var VertexActions    = require('actions/VertexActions');
  var EdgeActions      = require('actions/EdgeActions');
  var ModelActions     = require('actions/ModelActions');
  var ElementConstants = require('constants/ElementConstants');

  var self = this;

  self.on('update', function() {
    self.element = opts.selection[0] || opts.model;
    self.isMultipleSelection = opts.selection.length > 1;
    self.isEmptySelection = opts.selection.length == 0;
  });

  removeElement() {
    // Call proper remove action
    switch (self.element.type) {
      case ElementConstants.T_VERTEX:
        VertexActions.remove(opts.selection.mapBy('id'));
        break;
      case ElementConstants.T_EDGE:
        EdgeActions.remove(self.element.id);
        break;
      case ElementConstants.T_MODEL:
        ModelActions.remove(self.element.id);
        break;
    }
  }
</properties-pane>
