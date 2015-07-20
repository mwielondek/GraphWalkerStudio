<edge id="{ id }" source="{ sourceVertexId }" target="{ targetVertexId }">

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

  var self = this;
  self.defaults = {
    label: self.id + ': ' + self.sourceVertexId + '<->' + self.targetVertexId,
    status: Constants.status.UNVERIFIED
  };

  self.one('update', function() {
    // TODO: write custom extend func without overwrite
    // (i.e. extend self with defaults but dont overwrite)
    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);
  });

  self.on('mount', function() {
    self.connection = jsp.connect({source: self.sourceVertexId, target: self.targetVertexId});
    self.connection.getOverlay('label').setLabel(self.label);
    self.connection.setParameter('edge_id', self.id);
  });

  // don't do this for now.. riot/#1003
  // self.on('unmount', function() {
  //   jsp.detach(self.connection);
  // });
</edge>
