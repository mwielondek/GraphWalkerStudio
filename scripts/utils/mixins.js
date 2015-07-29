define(['jquery'], function($) {

  // Helper function for object arrays like `selection`
  Array.prototype.mapBy = function(prop) {
    return this.map(function(el) { return el[prop] });
  }

  // Get last item from array or undefined if empty
  Array.prototype.last = function() {
    return this[this.length - 1];
  }

  // Pluralize known words
  String.prototype.pluralize = function(flag) {
    var WORDS = {
      'vertex' : 'vertices'
    };
    return flag ? WORDS[this] : this;
  }

  // Compare two arrays
  $.fn.isSameAs = function(compareTo) {
    var len = this.length;
    if (!compareTo || len != compareTo.length) return false;
    for (var i = 0; i < len; ++i) {
      if (this[i] !== compareTo[i]) return false;
    }
    return true;
  };

  // Bind an event handler to execute first
  $.fn.bindFirst = function(name, fn) {
    var elem, handlers, i, _len;
    this.on(name, fn);
    for (i = 0, _len = this.length; i < _len; i++) {
      elem = this[i];
      handlers = jQuery._data(elem).events[name.split('.')[0]];
      handlers.unshift(handlers.pop());
    }
  };

});
