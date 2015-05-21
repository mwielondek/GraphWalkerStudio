(function() {
  // Default node properties
  nodeDefaults = {
    label: "New Node",
    width: 120,
    height: 80
  };

  Node = function(label, width, height) {
    this.label = label || this.defaults.label;
    this.width = width || this.defaults.width;
    this.height = height || this.defaults.height;
  };
  Node.prototype.defaults = nodeDefaults;
  Node.prototype.createElement = function() {
    var node = $("<div/>").addClass("node");
    $("<p></p>").text(this.label).addClass("label").appendTo(node);

    node.attr({
      "data-width": this.width,
      "data-height": this.height
    });

    node.css({
      "width": this.width,
      "height": this.height,
    });

    node.nodeObject = this;

    return node;
  };
})()

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
    var node = new Node().createElement();

    // set correct position within the graph
    node.css({
      "left": e.pageX - this.offsetLeft - (node.nodeObject.width / 2),
      "top": e.pageY - this.offsetTop - (node.nodeObject.height / 2)
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
