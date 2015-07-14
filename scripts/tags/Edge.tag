<edge>

  var $ = require('jquery');
  var jsp = require('jsplumb');
  var Constants = require('constants/EdgeConstants');

  var self = this;
  self.defaults = {
    label: 'New Edge',
    status: Constants.status.UNVERIFIED
  };

  self.one('update', function() {
    // TODO: write custom extend func without overwrite
    // (i.e. extend self with defaults but dont overwrite)
    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);
  });

  self.on('mount', function() {
    var connection = jsp.connect({source: self.source, target: self.target});
    connection.getOverlay('label').setLabel(self.label);
  });

  self.on('unmount', function() {
    jsp.detach({source: self.source, target: self.target});
  });
</edge>
