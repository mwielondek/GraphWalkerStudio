define(['riot', 'store/VertexStore', 'tag/Studio'],
function(riot) {

  var init = function(opts) {
    var opts = opts || {}
    return riot.mount('studio', opts);
  }

  return {
    init: init
  }
});
