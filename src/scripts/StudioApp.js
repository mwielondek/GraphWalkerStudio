define(['riot', 'store/VertexStore', 'store/EdgeStore', 'store/ConnectionStore',
 'store/ModelStore', 'tag/Studio', 'utils/mixins',
   'jquery',
   'app/RiotControl',
   'actions/VertexActions',
   'actions/EdgeActions',
   'jsplumb',
   'constants/StudioConstants',
   'tests/CanvasTest',
   'utils/rubberband',
   'constants/VertexConstants',
   'jquery-ui',
   'actions/Utils',
   'constants/EdgeConstants',
   'utils/mixins',
   'actions/ConnectionActions',
   'actions/ModelActions'
],
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
