define(['riot', 'store/VertexStore', 'store/EdgeStore', 'store/ConnectionStore',
 'store/ModelStore', 'store/GraphWalkerStore', 'tag/Studio', 'utils/mixins'],
function(riot) {

  var tagUtils = {
    // Toggles boolean variable
    toggle: function(variable) {
      return function() {
        this[variable] = !this[variable];
      };
    }
  };

  var init = function(opts) {
    // Mount the studio tag and return the mounted instance
    var opts = opts || {}
    riot.mixin('tagUtils', tagUtils);
    return riot.mount('studio', opts);
  }

  return {
    init: init
  }
});
