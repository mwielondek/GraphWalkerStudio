jsPlumb.ready(function() {
  var jsp = jsPlumb.getInstance({
    Container: "container",
    Endpoint: ["Dot", {radius: 2}],
    HoverPaintStyle: {strokeStyle: "#1e8151", lineWidth: 3 },
    PaintStyle: {strokeStyle: "#000000", lineWidth: 1 },
    ConnectionOverlays: [
        [ "Arrow", {
            location: 1,
            id: "arrow",
            length: 12,
            foldback: 0.1
        } ],
        [ "Label", { label: "Label", id: "label", cssClass: "edgeLabel" }]
    ],
  });

  // append new node to graph
  var addNode = function(e) {
    var node = $("<div/>").addClass("node");
    $("<p>Node</p>").addClass("label").appendTo(node);

    // set correct position within the graph
    node.css({
      "left": e.pageX - this.offsetLeft,
      "top": e.pageY - this.offsetTop
    });

    // append node to graph
    $(this).append(node);

    node.on("click", selectNode);
    jsp.draggable(node, {containment: true});
    jsp.setDraggable(node, false);

    jsp.addEndpoint(node, {
      isSource: true,
      endpoint: "Rectangle",
      paintStyle: {width: 20, height: 10, fillStyle: '#666'}
      });
    jsp.makeTarget(node, {
      dropOptions: { hoverClass: "dragHover" },
      anchor: "Continuous",
      allowLoopback: true
    });
  };
  var selectNode = function() {
    deselectAll();
    $(this).addClass("selected");
    jsp.setDraggable($(this), true);
    jsp.setSourceEnabled($(this), false);

    return false; // don't propagate - otherwise addNode is called
  };
  var deselectAll = function() {
    var selected = $(".node.selected");
    if (selected.length > 0) {
      jsp.setDraggable(selected, false);
      jsp.setSourceEnabled(selected, true);
      $(".node.selected").removeClass("selected");
    }
  };

  // add new nodes on click
  $("div#container")
    .on("dblclick", addNode)
    .on("click", deselectAll)
    // stop event propagation to disable handler on children elements
    .children().on("click", false);

  // dbg: export jsp instance
  window.jsp = jsp;
});
