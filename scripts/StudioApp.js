define(['riot', 'store/VertexStore', 'store/EdgeStore', 'store/ConnectionStore', 'tag/Studio'],
function(riot) {

  var init = function(opts) {
    // Mount the studio tag and return the mounted instance
    var opts = opts || {}
    return riot.mount('studio', opts);
  }

  return {
    init: init
  }
});
