<studio-canvas>
  <vertex each={ vertices } selection={ [parent.opts.selection.indexOf(id) != -1,
    parent.opts.selection.length] } selectvertex={ parent.opts.selectvertex }/>
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

  var $             = require('jquery');
  var jsp           = require('jsplumb');
  var RiotControl   = require('app/RiotControl');
  var VertexActions = require('actions/VertexActions');
  var EdgeActions = require('actions/EdgeActions');

  var self = this

  self.vertices = []
  self.edges = []

  addVertex(e) {
    // Prepare vertex object
    var vertex = {
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
      source: sourceId,
      target: targetId
    };
    EdgeActions.add(edge);
  }

  VertexActions.getAll(function(vertices) {
    self.vertices = vertices;
  });
  VertexActions.addChangeListener(function(vertices) {
    self.vertices = vertices;
    self.update();
  });

  EdgeActions.getAll(function(edges) {
    self.edges = edges;
  });
  EdgeActions.addChangeListener(function(edges) {
    self.edges = edges;
    self.update();
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
      // Handle connections => edge tag
      jsp.bind('beforeDrop', function(params) {
        self.addEdge(params.sourceId, params.targetId);
        return false;
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
        if (e.target == this) self.opts.selectvertex(0);
      })
      // Create a selection rubberband on click-n-drag
      .on('mousedown', function(evt) {
        // Record the starting point
        var startpos = {
          Y: evt.pageY - this.offsetTop,
          X: evt.pageX - this.offsetLeft
        };

        // Create the rubberband div and append it to container
        var rb = $("<div/>").attr("id", "rubberband").css({
          top: startpos.Y,
          left: startpos.X
        }).appendTo(this);

        // Append temporary handlers
        $(this)
          .on("mousemove", function(emv) {
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
            self.opts.selectvertex(selectedVertices.map(function(el) {
              return el.id;
            }), append);


            // Remove rubberband
            setTimeout(function() {
              rb.remove(); // HACK: if we call `remove` without `setTimeout`
                           // it will prevent the click from falling through.
            }, 0);

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
