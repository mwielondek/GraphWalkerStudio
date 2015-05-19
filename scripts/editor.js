jsPlumb.ready(function() {
  var jsp = jsPlumb.getInstance({
    Container: "container"
  });

  // append new node to graph
  var addNode = function(e) {
    var node = $("<div class=\"node\"><p class=\"label\">New Node</p></div>");
    // set correct position within the graph
    node.css("left", e.pageX - this.offsetLeft);
    node.css("top", e.pageY - this.offsetTop);
    jsp.draggable(node);  // make draggable
    node.click(false);    // disable addNode handler on node
    $(this).append(node); // append
  };

  // add new nodes on click
  $("div#container")
    .on("click", addNode)
    // stop event propagation to disable handler on children elements
    .children().on("click", false);

  // dbg: export jsp instance
  window.jsp = jsp;
});
