<edge id="{ id }" source="{ sourceVertexId }" target="{ targetVertexId }">
<editable type="text" callback={ changeName } off={ !selected }>{ name }</editable>

  <style>
  .edge-label {
    background-color: white;
    opacity: 0.8;
    padding: 5px;
    border: 1px solid black;
    min-width: 10px;
    min-height: 8pt;
  }

  .edge-label:empty:not(:hover):not(:focus) {
    opacity: 0;
  }
  </style>

  var $ = require('jquery');
  var jsp = require('jsplumb');
  var Constants = require('constants/EdgeConstants');
  var EdgeActions = require('actions/EdgeActions');

  var self = this;
  self.defaults = {
    status: Constants.status.UNVERIFIED
  };

  self.one('update', function() {
    // TODO: write custom extend func without overwrite
    // (i.e. extend self with defaults but dont overwrite)
    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);
  });

  self.on('mount', function() {
    self.connection = jsp.connect({source: self.sourceDomId, target: self.targetDomId});
    self.connection.setParameter('_edgeObject', self);

    // Append editable
    var labelElement = $(self.root).find('editable').detach();
    $(self.connection.getOverlay('label').getElement()).append(labelElement);

    // Fix the loopback connection spawning off center
    if (self.sourceDomId == self.targetDomId)
      setTimeout(function() {jsp.revalidate(self.sourceDomId)}, 0);

    EdgeActions.setProps(self.id, {_jsp_connection: self.connection});
  });

  self.on('update', function() {
    self.selected = self.opts.selection.mapBy('id').contains(self.id);
  });

  self.on('updated', function() {
    // Set proper style when selected
    var connection = self.connection;
    var SELECTED = 'selected';
    if (connection && connection.connector) {
      if (self.selected && !connection.hasType(SELECTED)) connection.addType(SELECTED);
      if (!self.selected && connection.hasType(SELECTED)) connection.removeType(SELECTED);
    }
  })

  self.on('unmount', function() {
    if (self.connection.connector) jsp.detach(self.connection);
  });

  changeName(newValue) {
    var props = {name: newValue};
    EdgeActions.setProps(self.id, props);
  }
</edge>
