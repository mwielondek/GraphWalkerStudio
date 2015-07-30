define(['jquery'], function($) {

  // Extract given property for all elements in an array.
  // Accepts nested arguments like eg. `mapBy('foo.bar')`.
  Array.prototype.mapBy = function(prop) {
    var props = prop.split('.');
    return this.map(function(el) {
      props.forEach(function(prop) {
        el = el[prop];
      });
      return el;
    });
  }

  // Get last item from array or undefined if empty
  Array.prototype.last = function() {
    return this[this.length - 1];
  }

  // Remove given element from array
  Array.prototype.remove = function(el) {
    var index = this.indexOf(el);
    if (index != -1) this.splice(index, 1);
  }

  // Check if element is in array
  Array.prototype.contains = function(el) {
    return this.indexOf(el) != -1;
  }

  // Empty the array
  Array.prototype.clear = function() {
    this.length = 0;
  }

  // Removes an element if it exists, otherwise add it
  Array.prototype.toggle = function(el) {
    var index = this.indexOf(el);
    if (index != -1) {
      this.remove(el);
    } else {
      this.push(el);
    }
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
