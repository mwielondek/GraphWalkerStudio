jsPlumb.ready(function() {
  var jsp = jsPlumb.getInstance({
    Container: "container"
  });

  // append new node to graph
  var addNode = function(e) {
    var node = $("<div class=\"node\"/>");
    node.append("<p class=\"label\">New Node</p>");

    // set correct position within the graph
    node.css("left", e.pageX - this.offsetLeft);
    node.css("top", e.pageY - this.offsetTop);

    // append node to graph
    $(this).append(node);
    node.on("click", selectNode);
    jsp.draggable(node, {containment: true});
    jsp.setDraggable(node, false);

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
