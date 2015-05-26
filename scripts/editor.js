var editor = (function($, jsPlumb) {
  var jsp; // jsPlumbInstance

  // Default vertice properties
  var verticeDefaults = {
    label: "New Vertice",
    width: 120,
    height: 80
  };

  var Vertice = function(label, width, height) {
    this.label = label || this.defaults.label;
    this.width = width || this.defaults.width;
    this.height = height || this.defaults.height;
  };
  Vertice.prototype.defaults = verticeDefaults;
  Vertice.prototype.createElement = function() {
    var vertice = $("<div/>").addClass("vertice");
    $("<p></p>").text(this.label).addClass("label").appendTo(vertice);

    vertice.attr({
      "data-width": this.width,
      "data-height": this.height
    });

    vertice.css({
      "width": this.width,
      "height": this.height,
    });

    vertice.verticeObject = this;

    return vertice;
  };

  // append new vertice to graph
  var addVertice = function(e) {
    var vertice = new Vertice().createElement();

    // set correct position within the graph
    vertice.css({
      "left": e.pageX - this.offsetLeft - (vertice.verticeObject.width / 2),
      "top": e.pageY - this.offsetTop - (vertice.verticeObject.height / 2)
    });

    // append vertice to graph
    $(this).append(vertice);

    // properly handle click and drag events
    (function(vertice) {
      var isDragEvent = false;
      vertice.addEventListener("mousedown", function(evt) {
        // TODO check the vertice object for selected attr instead of hasClass
        if (isDragEvent || $(this).hasClass("selected")) {
          isDragEvent = false;
          return;
        }
        evt.stopImmediatePropagation();
        $(this).on("mouseup mouseleave", function handler(e) {
          if (e.type == "mouseup") {
            // click
            selectVertice.call(this);
          } else {
            // drag
            isDragEvent = true;
            var msdwn = new MouseEvent("mousedown", {
              clientX: e.clientX,
              clientY: e.clientY
            });
            this.dispatchEvent(msdwn);
          }
          $(this).off("mouseup mouseleave", handler)
        });
      }, true); // use capture
    })(vertice.get(0));

    jsp.draggable(vertice, {
      containment: true,
      filter: ".ui-resizable-handle"
      });
    jsp.setDraggable(vertice, false);

    jsp.makeSource(vertice, {
      anchor: "Continuous",
      connector: ["StateMachine", {
        curviness: 0,
        proximityLimit: 260 }],
    })
    jsp.makeTarget(vertice, {
      dropOptions: { hoverClass: "dragHover" },
      anchor: "Continuous",
      allowLoopback: true
    });
  };
  var selectVertice = function() {
    deselectAll();
    var $this = $(this);
    $this.addClass("selected");
    $this.resizable({
      resize: function(e, ui) {
        jsp.revalidate(ui.element.get(0));
      }
    });
    jsp.setDraggable($this, true);
    jsp.setSourceEnabled($this, false);

    return false; // don't propagate - otherwise addVertice is called
  };
  var deselectAll = function() {
    var selected = $(".vertice.selected");
    if (selected.length > 0) {
      jsp.setDraggable(selected, false);
      jsp.setSourceEnabled(selected, true);
      selected.removeClass("selected");
      selected.resizable("destroy");
    }
  };

  var init = function(jsPlumbInstance) {
    jsp = jsPlumbInstance;

    $("div#container")
      .on("dblclick", addVertice)    // add new vertices on double click
      .on("click", function(e) {  // clear selected vertices on click
        // only when clicked directly on the container
        if (e.target === this) deselectAll();
      });
  }

  return {
    init: init
  }
})(jQuery, jsPlumb)

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

  // dbg: export jsp instance
  window.jsp = jsp;

  editor.init(jsp);
});
