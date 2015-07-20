<studio-canvas>
  <vertex each={ vertices } selection={ [parent.opts.selection.mapBy('id').indexOf(id) != -1,
    parent.opts.selection.length] } updateselection={ parent.opts.updateselection }/>
  <edge each={ edges } />

  <style>
  studio-canvas {
    height: 100%;
    display: block;
    position: relative;
    margin-right: 320px;
    background-color: #f0f0f0;
  }
  </style>

  var $                = require('jquery');
  var jsp              = require('jsplumb');
  var RiotControl      = require('app/RiotControl');
  var VertexActions    = require('actions/VertexActions');
  var EdgeActions      = require('actions/EdgeActions');
  var ElementConstants = require('constants/ElementConstants');

  var self = this

  self.vertices = []
  self.edges = []

  addVertex(e) {
    // Prepare vertex object
    var vertex = {
      type: ElementConstants.T_VERTEX,
      view: {
        centerY: e.pageY - self.root.offsetTop,
        centerX: e.pageX - self.root.offsetLeft
      }
    }
    // Dispatch action
    VertexActions.add(vertex);
  }

  addEdge(sourceId, targetId) {
    var edge = {
      type: ElementConstants.T_EDGE,
      sourceVertexId: sourceId,
      targetVertexId: targetId
    };
    EdgeActions.add(edge);
  }

  VertexActions.getAll(function(vertices) {
    self.vertices = vertices;
  });
  VertexActions.addChangeListener(function(vertices) {
    self.vertices = vertices;
    self.opts.updateselection(0);
  });

  EdgeActions.getAll(function(edges) {
    self.edges = edges;
  });
  EdgeActions.addChangeListener(function(edges) {
    self.edges = edges;
    self.opts.updateselection(0);
  });

  self.on('mount', function() {
    // Init jsPlumb
    jsp.ready(function() {
      // Defaults
      jsp.importDefaults({
        Endpoint: ['Dot', {radius: 2}],
        Anchor: 'Continuous',
        Connector: [
          'StateMachine', {
            curviness: 0,
            proximityLimit: 260
        }],
        HoverPaintStyle: {strokeStyle: '#0b771b', lineWidth: 3 },
        PaintStyle: {strokeStyle: '#000000', lineWidth: 1 },
        ConnectionOverlays: [
            [ 'Arrow', {
                location: 1,
                id: 'arrow',
                length: 12,
                foldback: 0.1
            } ],
            [ 'Label', { id: 'label', cssClass: 'edge-label' }]
        ]
      });

      // Set canvas as container
      jsp.setContainer(self.root);

      // Move connection creation logic to `edge` tag.
      jsp.bind('beforeDrop', function(params) {
        self.addEdge(params.sourceId, params.targetId);
        return false;
      });

      // Selecting edges
      jsp.bind('click', function(params) {
        var edgeId = params.getParameter('edge_id');
        self.opts.updateselection(edgeId, ElementConstants.T_EDGE);
      });
    });

    // Set up event listeners
    $(self.root)
      // Add new vertices on double click
      .on('dblclick', function(e) {
        if (e.target === this) self.addVertex(e);
      })
      // Deselect vertices on click
      .on('click', function(e) {
        if (e.target == this) self.opts.updateselection(0);
      })
      // Create a selection rubberband on click-n-drag
      .on('mousedown', function(evt) {
        // Trigger only when clicked directly on canvas to prevent
        // rubberband appearing when e.g. resizing vertices.
        if (evt.target !== this) return;

        // Record the starting point
        var startpos = {
          Y: evt.pageY - this.offsetTop,
          X: evt.pageX - this.offsetLeft
        };

        // Create the rubberband div and append it to container
        var rb = $("<div/>").attr("id", "rubberband").css({
          top: startpos.Y,
          left: startpos.X
        }).hide().appendTo(this);

        // Append temporary handlers
        $(this)
          .on("mousemove", function(emv) {
            // Don't display the rubberband until user moves the cursor
            rb.show();

            // Update dimensions
            rb.css({
              "top":    Math.min(startpos.Y, emv.pageY - this.offsetTop),
              "left":   Math.min(startpos.X, emv.pageX - this.offsetLeft),
              "width":  Math.abs(startpos.X - emv.pageX + this.offsetLeft),
              "height": Math.abs(startpos.Y - emv.pageY + this.offsetTop)
            });
          })
          .on("mouseup", function(eup) {
            // Add to existing selection if meta key is down
            var append = eup.metaKey;

            // Select vertices that (fully) fall inside the rubberband
            var selectedVertices = getSelectedVertices(rb[0]);
            self.opts.updateselection(selectedVertices.map(function(el) {
              return el.id;
            }), ElementConstants.T_VERTEX, append);

            // Remove rubberband
            rb.remove();

            // Remove handlers
            $(this).off("mouseup mousemove");
          });
      });

      // Rubberband helper functions
      var getElementOffset = function(element) {
        var elementOffset = {};
        elementOffset.left = element.offsetLeft;
        elementOffset.top =  element.offsetTop;

        // Distance to the right is: left + width
        elementOffset.right = elementOffset.left + element.offsetWidth;

        // Distance to the bottom is: top + height
        elementOffset.bottom = elementOffset.top + element.offsetHeight;

        return elementOffset;
      };
      var getSelectedVertices = function(rubberband) {
        var selectedVertices = [];
        var rubberbandOffset = getElementOffset(rubberband);
        $("vertex").each(function(i,el) {
          var itemOffset = getElementOffset(this);
          // Check if vertex falls inside the rubberband
          if(itemOffset.top > rubberbandOffset.top &&
            itemOffset.left > rubberbandOffset.left &&
            itemOffset.right < rubberbandOffset.right &&
            itemOffset.bottom < rubberbandOffset.bottom) {
              // If it does, add it to selection
              selectedVertices.push(this);
            }
        });
        return selectedVertices;
      };
  });

  self.on('update', function() {
    // TODO: figure out why it's triggered twice on selection
    var selection = self.opts.selection;
    jsp.clearDragSelection();
    jsp.addToDragSelection(selection);
  });
</studio-canvas>
