var editor = (function($, jsPlumb) {
  var jsp; // jsPlumbInstance

  // Default vertex properties
  var vertexDefaults = {
    label: "New Vertex",
    width: 120,
    height: 80
  };

  var Vertex = function(label, width, height) {
    this.label = label || this.defaults.label;
    this.width = width || this.defaults.width;
    this.height = height || this.defaults.height;
  };
  Vertex.prototype.defaults = vertexDefaults;
  Vertex.prototype.createElement = function() {
    var vertex = $("<div/>").addClass("vertex").attr("tabindex","0");
    var label = $("<p/>").text(this.label).addClass("label");
    $("<div/>").addClass("label-div").append(label).appendTo(vertex);

    vertex.attr({
      "data-width": this.width,
      "data-height": this.height
    });

    vertex.css({
      "width": this.width,
      "height": this.height,
    });

    vertex.vertexObject = this;

    return vertex;
  };

  // Append new vertex to graph
  var addVertex = function(mouseEvent) {
    var vertex = new Vertex().createElement();

    // Set correct position within the graph
    vertex.css({
      "left": mouseEvent.pageX - this.offsetLeft - (vertex.vertexObject.width / 2),
      "top": mouseEvent.pageY - this.offsetTop - (vertex.vertexObject.height / 2)
    });

    // Append vertex to graph
    $(this).append(vertex);

    // Set label edit handler
    editLabel.attachHandlerOn(vertex.find(".label"), function() {
      // Return forcus to vertex after edit
      vertex.focus();
    });

    // Properly handle click and drag events
    (function(vertex) {
      var isDragEvent = false;
      vertex.on("mousedown", function(evt) {
        // Don't set focus yet
        evt.preventDefault();

        // Set "click" handler
        $(this).on("mouseup", function(e) {
          // Ignore if cursor has moved
          if (!mouseMoved(evt,e)) {
            // If clicked when holding down meta key add vertex to
            // current selection OR remove it if already selected,
            // otherwise create new selection.
            var selection = e.metaKey ? $(".vertex-selected").selectorToggle(this) : $(this);
            selection.selectVertex();
          }
          // Disable both handlers after click or drag
          $(this).off("mouseleave mouseup");
        });

        // If it's a drag event or if the vertex already is selected, do nothing
        if (isDragEvent || $(this).hasClass("vertex-selected")) {
          isDragEvent = false;
          return;
        }
        // Stop event from triggering jsPlumb's handlers (and making a new connection)
        evt.stopImmediatePropagation();

        // When the cursor leaves the vertex trigger a drag
        $(this).on("mouseleave", function(e) {
          // Dispatch the original mousedown event again this time with the
          // isDragEvent flag to prevent the mux from intercepting it, resulting
          // in a drag.
          isDragEvent = true;

          // Since evt is a jQuery Event we can't pass it directly to dispatchEvent,
          // but need to create a new event with the same cursor coordinates.
          var msdwn = new MouseEvent("mousedown", {
            clientX: e.clientX,
            clientY: e.clientY
          });
          this.dispatchEvent(msdwn);
          // Disable both handlers after click or drag
          $(this).off("mouseleave mouseup");
        });
      });
    })(vertex);

    vertex
      .on("focus", function() {
        $(this).selectVertex();
      })
      .on("keydown", function(e) {
        var selected = $(".vertex-selected");
        if (e.which === 8 || e.which === 46) {
          // remove all selected vertices by pressing backspace or delete
          jsp.remove(selected);
        } else if (e.which === 13 && selected.length == 1) {
          // enter label editing mode on enter press
          e.preventDefault();
          editLabel.handler.call($(this).find(".label").get(0));
        };
      });

    jsp.draggable(vertex, {
      containment: true,
      filter: ".ui-resizable-handle"
      });
    jsp.setDraggable(vertex, false);

    jsp.makeSource(vertex, {
      anchor: "Continuous",
      connector: ["StateMachine", {
        curviness: 0,
        proximityLimit: 260 }],
    })
    jsp.makeTarget(vertex, {
      dropOptions: { hoverClass: "drag-hover" },
      anchor: "Continuous",
      allowLoopback: true
    });
  };

  $.fn.selectVertex = function() {
    // When selecting a single vertex, give it focus
    if (this.length == 1 && !this.hasFocus()) {
      this.focus();
      // exit here since the focus handler will retrigger this function
      return;
    }
    // first deselect all vertices
    $(".vertex-selected").deselectVertex();
    // set selected properties
    this.toggleClass("vertex-selected");
    jsp.setDraggable(this, true);
    jsp.setSourceEnabled(this, false);
    if (this.length > 1) {
      // if multiple vertices are selected, add to multi-drag-selection
      jsp.addToDragSelection(this);
    } else {
      // only make resizable if a single vertex is selected
      this.resizable({
        resize: function(e, ui) {
          jsp.revalidate(ui.element.get(0));
        }
      });
    }
  };
  $.fn.deselectVertex = function() {
    // if no vertices are selected do nothing
    if (this.length == 0 || !this.hasClass("vertex-selected")) return;
    this.toggleClass("vertex-selected");
    jsp.clearDragSelection();
    jsp.setDraggable(this, false);
    jsp.setSourceEnabled(this, true);
    if (this.length == 1) this.resizable("destroy");
  };
  // Toggle selector. If selector is present remove it, if not present add it.
  $.fn.selectorToggle = function(selector) {
    return this.is(selector) ? this.not(selector) : this.add(selector);
  }
  $.fn.hasFocus = function() {
    // TODO create exception object?
    if (this.length > 1) throw "Error: cannot check multiple elements for focus"
    return this.get(0) === document.activeElement;
  }
  var mouseMoved = function(event, otherEvent, tolerance) {
    var tolerance = tolerance || 1;
    return (Math.abs(event.clientX - otherEvent.clientX) > tolerance
        || Math.abs(event.clientY - otherEvent.clientY) > tolerance);
  }
  // RUBBERBAND
  var getTopLeftOffset = function(element) {
    var elementDimension = {};
    elementDimension.left = element.offset().left;
    elementDimension.top =  element.offset().top;

    // Distance to the left is: left + width
    elementDimension.right = elementDimension.left + element.outerWidth();

    // Distance to the top is: top + height
    elementDimension.bottom = elementDimension.top + element.outerHeight();

    return elementDimension;
  };
  var selectMarkedVertices = function(rubberband, append) {
    var rubberbandOffset = getTopLeftOffset(rubberband);
    // If flag is set append to exisiting selection, otherwise make new selection
    var selection = append ? $(".vertex-selected") : $();
    $(".vertex").each(function() {
      var itemOffset = getTopLeftOffset($(this));
      if(itemOffset.top > rubberbandOffset.top &&
        itemOffset.left > rubberbandOffset.left &&
        itemOffset.right < rubberbandOffset.right &&
        itemOffset.bottom < rubberbandOffset.bottom) {
          selection = selection.selectorToggle($(this));
        }
    });
    if (selection.length > 0) selection.selectVertex();
  };

  var editLabel = (function() {
    var oldValue;
    return {
      handler: function() {
        // If the element already is editable do nothing. This event might
        // fire when user tries to select a word in the label by dblclick.
        if ($(this).attr("contenteditable") === "true") {
          return;
        };
        // Disable noselect class and enable editing the element
        $("#container").toggleClass("noselect");
        $(this).attr("contenteditable","true");
        // Stash away old value in order to be able to restore it if user
        // presses escape, and preselect all text on focus.
        var range = document.createRange(),
            sel = window.getSelection();
        range.selectNodeContents(this);
        sel.removeAllRanges();
        sel.addRange(range);
        oldValue = sel.getRangeAt(0).startContainer.textContent;
      },
      attachHandlerOn: function(el, callback) {
        $(el).on("mousedown", function(e) {
          // Keep focus on clicks to allow normal mouse interaction with
          // the text selection by preventing the event from bubbling
          e.stopPropagation();
        })
        .on("dblclick", this.handler)
        .on("keydown blur", function(e) {
          // Turn off editing mode on escape, enter or mouseclick outside
          switch(e.which) {
            case 27:  // escape
              // Discard changes and restore old value
              $(this).text(oldValue);
            case 13:  // enter
              // Remove focus from element -- will call handler again
              // due to the break statement preventing fallthrough
              this.blur();
              break;
            case 0:   // blur
              // Disable editing mode
              $(this).attr("contenteditable","false");
              $("#container").toggleClass("noselect");
              // If we try to set label to the empty string a br tag
              // is automatically added - remove it.
              if ($(this).text() === "") $(this).children("br").remove();
              // Callback
              if (callback) callback($(this).text());
          }
          // Prevent keypresses bubbling to div (eg. prevent remove on del/bksp)
          e.stopPropagation();
        });
      }
    };
  })();

  // ====================  INIT ==================== //
  var init = function(jsPlumbInstance) {
    jsp = jsPlumbInstance;

    $("div#container")
      // Add new vertices on double click
      .on("dblclick", function(e) {
        if (e.target === this) addVertex(e);
      })
      // Deselect vertices on click
      .on("click", function(e) {
        var selectedVertices = $(".vertex-selected");
        if (e.target === this) selectedVertices.deselectVertex();
      })
      // Create a selection rubberband on click-n-drag
      .on("mousedown", function(edwn) {
        var startpos = {
          Y: edwn.pageY - this.offsetTop,
          X: edwn.pageX - this.offsetLeft
        };

        // Create the rubberband div and append it to container
        var rb = $("<div/>").addClass("rubberband").css({
          top: startpos.Y,
          left: startpos.X
        }).hide().appendTo(this);

        // Append handlers
        $(this)
          .on("mousemove", function(emv) {
            // Show rubberband
            if (!rb.is(":visible")) rb.show();

            // Update dimensions
            rb.css({
              "top": Math.min(startpos.Y, emv.pageY - this.offsetTop),
              "left": Math.min(startpos.X, emv.pageX - this.offsetLeft),
              "width": Math.abs(startpos.X - emv.pageX + this.offsetLeft),
              "height": Math.abs(startpos.Y - emv.pageY + this.offsetTop)
            });
          })
          .on("mouseup", function(eup) {
            // Add to existing selection if meta key is down
            var append = eup.metaKey;
            // Select vertices that (fully) fall inside the rubberband
            selectMarkedVertices(rb, append);

            // Remove rubberband
            rb.remove();

            // Remove handlers
            $(this).off("mouseup mousemove");
          });
      })
      // Disable text selection to prevent vertex labels
      // getting highlighted when creating new vertices
      .addClass("noselect");

    // Bind the target DOM of addVertex
    addVertex = addVertex.bind($("#container").get(0));

    // Define selected edge style
    var selectedEdge = {
      paintStyle: { strokeStyle: "#25bb72", lineWidth: 3 }
    }
    jsp.registerConnectionType("selected", selectedEdge);

    // On new connection
    jsp.bind("connection", function(info) {
      // Attach label edit handler
      var jspLabel = info.connection.getOverlay("label");
      jspLabel.setLabel("Label"); // TODO fetch pre-set default value
      var label = jspLabel.getElement();
      editLabel.attachHandlerOn(label, function() {
        // Return focus to connector when finished editing
        connector.focus();
      });

      // Attach edge selection handler
      var connector = $(info.connection.connector.canvas);
      // Make connector not keyboard focusable
      connector.attr("tabindex","-1");
      connector.on("keydown", function(e) {
        if (e.which === 8 || e.which === 46) {
          // Remove selected edge by pressing backspace or delete
          this.blur();
          jsp.detach(info.connection);
        } else if (e.which === 13) {
          // Enter label editing mode on enter press
          e.preventDefault();
          editLabel.handler.call(label);
        };
      });
      connector.on("focus blur", function() {
        info.connection.toggleType("selected");
      });
    });

    // When an edge is clicked
    jsp.bind("click", function(conn) {
      conn.connector.canvas.focus();
      $(".vertex-selected").deselectVertex();
    });

    // Fix setDraggable not handling arrays of
    // elements correctly (see jsPlumb #383)
    jsp._setDraggable = jsp.setDraggable;
    jsp.setDraggable = function(elems, draggable) {
      if (!(elems instanceof jQuery)) elems = [elems];
      $.each(elems, function(_, el) {
        jsp._setDraggable(el, draggable);
      });
    }

    // Extend jsPlumb.remove to handle multiple elements
    jsp._remove = jsp.remove;
    jsp.remove = function(elems) {
      if (!(elems instanceof jQuery)) elems = [elems];
      $.each(elems, function(_, el) {
        jsp._remove(el);
      });
    }
  };

  return {
    init: init
  };
})(jQuery, jsPlumb)

jsPlumb.ready(function() {
  var jsp = jsPlumb.getInstance({
    Container: "container",
    Endpoint: ["Dot", {radius: 2}],
    HoverPaintStyle: {strokeStyle: "#0b771b", lineWidth: 3 },
    PaintStyle: {strokeStyle: "#000000", lineWidth: 1 },
    ConnectionOverlays: [
        [ "Arrow", {
            location: 1,
            id: "arrow",
            length: 12,
            foldback: 0.1
        } ],
        [ "Label", { id: "label", cssClass: "edge-label" }]
    ],
  });

  // DBG: export jsp instance
  window.jsp = jsp;

  editor.init(jsp);
});
