define(['riot', 'store/VertexStore', 'store/ConnectionStore', 'tag/Studio'],
function(riot) {

  var init = function(opts) {
    var opts = opts || {}
    return riot.mount('studio', opts);
  }

  return {
    init: init
  }
});
