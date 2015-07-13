<edge>
  <p>{ label }</p>

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
    jsp.connect({source: self.source, target: self.target});
  });
</edge>
