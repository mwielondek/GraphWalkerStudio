define(['riot', 'jsplumb', 'store/VertexStore', 'store/ConnectionStore', 'tag/Studio'],
function(riot, jsPlumb) {

  var init = function(opts) {
    // Init jsPlumb
    jsPlumb.importDefaults({
      PaintStyle : {
        lineWidth:3,
        strokeStyle: '#000000',
      },
      DragOptions : { cursor: "crosshair" },
      Endpoints : [ [ "Dot", { radius:3 } ], [ "Dot", { radius:3 } ] ],
      EndpointStyles : [{ fillStyle:"#225588" }, { fillStyle:"#558822" }]
    });

    // Mount the studio tag and return the mounted instance
    var opts = opts || {}
    return riot.mount('studio', opts);
  }

  return {
    init: init
  }
});
