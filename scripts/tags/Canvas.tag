<studio-canvas class="{ highlight: !selection.length }">
  <div class="zoom-button" id="zoom-in">+</div>
  <div class="zoom-button" id="zoom-out">–</div>
  <input type="range" id="zoom-range" step="0.05" min="0.4" max="5">
  <div id="canvas-body">
    <vertex each={ filterByModel(vertices) } selection={ parent.opts.selection } />
    <edge each={ filterByModel(edges) } selection={ parent.opts.selection } />
  </div>

  <style>
    studio-canvas {
      height: 100%;
      display: block;
      margin-right: 310px;
      border: 2px solid #10586b;
      overflow: hidden;
      position: relative;
    }
    studio-canvas.highlight {
      border: 2px solid #2cb9de;
    }
    #canvas-body {
      background: #f0f0f0;
      background-image: url('grid.png');
      background-blend-mode: overlay;
      position: absolute;
      -webkit-backface-visibility: initial !important;
      -webkit-transform-origin: 50% 50%;
    }
    .zoom-button {
      text-align: center;
      background-color: navy;
      color: white;
      width: 20px;
      height: 20px;
      position: absolute;
      top: 10px;
      z-index: 1;
    }
    #zoom-range {
      position: absolute;
      top: 100px;
      right: -42px;
      z-index: 1;
      transform: rotate(270deg);
      -webkit-transform: rotate(270deg);
    }
    #zoom-in {
      right: 5px;
    }
    #zoom-out {
      right: 27px;
    }
  </style>

  var $                 = require('jquery');
  var jsp               = require('jsplumb');
  var RiotControl       = require('app/RiotControl');
  var VertexActions     = require('actions/VertexActions');
  var EdgeActions       = require('actions/EdgeActions');
  var ModelActions      = require('actions/ModelActions');
  var ActionUtils       = require('actions/Utils');
  var StudioConstants   = require('constants/StudioConstants');
  var ConnectionActions = require('actions/ConnectionActions');
  var rubberband        = require('utils/rubberband');

  var LEFT_BUTTON  = 0;
  var RIGHT_BUTTON = 2;
  var ALT_KEY    = 91;
  var ALT_KEY_FF = 224; // Firefox uses a different keycode for ALT for some reason.
  var SPACEBAR   = 32;
  var SHIFT_KEY  = 16;

  // Canvas dimensions
  var CANVAS_SIZE = 10000;

  var self = this

  self.vertices = []
  self.edges = []

  addVertex(e) {
    // Prepare vertex object
    var vertex = {
      modelId: opts.model.id,
      view: {
        centerY: e.offsetY,
        centerX: e.offsetX
      }
    }
    // Dispatch action
    VertexActions.add(vertex);
  }

  addEdge(sourceDomId, targetDomId) {
    var sourceVertexId = $('#'+sourceDomId).attr('vertex-id');
    var targetVertexId = $('#'+targetDomId).attr('vertex-id');
    var edge = {
      modelId: opts.model.id,
      sourceDomId: sourceDomId,
      targetDomId: targetDomId,
      sourceVertexId: sourceVertexId,
      targetVertexId: targetVertexId
    };
    EdgeActions.add(edge);
  }

  filterByModel(elements) {
    return elements.filter(function(el) { return el.modelId == opts.model.id });
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
    // Set canvas dimensions and center it
    $('#canvas-body').css({
      height: CANVAS_SIZE,
      width: CANVAS_SIZE,
      top: -CANVAS_SIZE/2,
      left: -CANVAS_SIZE/2
    });

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

      // Register connection types
      jsp.registerConnectionType('selected', {
        // Same as HoverPaintStyle
        paintStyle: {strokeStyle: '#0b771b', lineWidth: 3 }
      });

      // Set canvas as container
      jsp.setContainer('canvas-body');

      // Move connection creation logic to `edge` tag.
      jsp.bind('beforeDrop', function(params) {
        self.addEdge(params.sourceId, params.targetId);
        return false;
      });

      // Selecting edges
      jsp.bind('click', function(connection, evt) {
        var edge = connection.getParameter('_edgeObject');
        self.opts.selection.update(edge, evt.metaKey);
      });
    });

    // Append rubberband listener
    rubberband('#canvas-body', 'vertex', function(selectedVertices, append) {
      // Dispatch it to end of event queue so that it is not
      // overriden by the onClick handler below.
      setTimeout(function() {
        self.opts.selection.update(selectedVertices.mapBy('_vertexObject'), append);
      }, 0);
    });

    // Set up event listeners
    $('#canvas-body')
      // Add new vertices on double click
      .on('dblclick', function(e) {
        if (e.target === this && !e.metaKey) self.addVertex(e);
      })
      // Deselect vertices on click
      .on('click', function(e) {
        if (e.target == this) self.opts.selection.clear();
      })
      .on('mousedown', function(e) {
        // Create rubberband on left click-n-drag
        if (e.button == LEFT_BUTTON) {
          $(this).trigger('rubberband', e);
        } else {
          $(this)
            .css('cursor', 'grabbing')
            .css('cursor', '-webkit-grabbing')
            .one('mouseup', function() {
              $(this).css('cursor', 'default');
            })
        }
      })
      .on('contextmenu', function(e) {
        e.preventDefault();
      });

    // Set up panning & zooming
    var _updateModel = function() {
      // Store pan position in model
      ActionUtils.timeBufferedAction(function() {
        ModelActions.setProps(opts.model.id, {
          view: {
            panzoom: $('#canvas-body').panzoom('getMatrix')
          }
        });
      }, 'model.update.panzoom', 400);
    };
    $('#canvas-body').panzoom({
      cursor: 'default',
      contain: 'invert', // Don't show what's behind canvas
      onEnd: _updateModel,
      $zoomIn: $('#zoom-in'),
      $zoomOut: $('#zoom-out'),
      $zoomRange: $('#zoom-range'),
      onZoom: function(e, pz, scale) {
        jsp.setZoom(scale);
        _updateModel();
      },
      onReset: function() {
        // Find bounding box of all vertices and set zoom and pan around it
        if (self.vertices.length) {
          // Get bounding box
          var bounds = {
            left: CANVAS_SIZE,
            top: CANVAS_SIZE,
            right: 0,
            bottom: 0,
            get size() {
              return {
                width: this.right - this.left,
                height: this.bottom - this.top
              }
            },
            get center() {
              return {
                x: this.size.width/2 + this.left,
                y: this.size.height/2 + this.top,
              }
            }
          };
          self.filterByModel(self.vertices).forEach(function(el) {
            bounds.left   = Math.min(bounds.left, el.view.left);
            bounds.top    = Math.min(bounds.top, el.view.top);
            bounds.right  = Math.max(bounds.right, el.view.left + el.view.width);
            bounds.bottom = Math.max(bounds.bottom, el.view.top + el.view.height);
          });

          var viewport = {
            height: this.offsetParent.clientHeight,
            width: this.offsetParent.clientWidth
          };

          // Calculate pan
          var CENTER_OFFSET = 0;
          var pan = {
            x: CANVAS_SIZE/2 - bounds.center.x + viewport.width/2 - CENTER_OFFSET,
            y: CANVAS_SIZE/2 - bounds.center.y + viewport.height/2 - CENTER_OFFSET
          }
          $(this).panzoom('pan', pan.x, pan.y);

          // Calculate zoom
          var ZOOM_OFFSET = {
            x: this.offsetParent.offsetLeft,
            y: this.offsetParent.offsetTop
          };
          var ZOOM_MARGIN = 0.02; // Provide a margin between elements and canvas walls
          var zoom = Math.min(
            viewport.height / bounds.size.height,
            viewport.width  / bounds.size.width
          );
          $(this).panzoom('zoom', zoom > 0 ? Math.min(zoom - ZOOM_MARGIN, 1) : 1, {
            focal: {
              clientX: (CANVAS_SIZE + viewport.width)/2 + ZOOM_OFFSET.x,
              clientY: (CANVAS_SIZE + viewport.height)/2 + ZOOM_OFFSET.y
            }
          });

        }
        _updateModel();
      }
    })
    // Mousewheel zooming (doesn't support Firefox)
    .on('mousewheel', function( e ) {
      // Don't scroll container
      e.preventDefault();

      // Zoom in or out?
      var delta = e.delta || e.originalEvent.wheelDelta;
      var zoomOut = delta ? delta < 0 : e.originalEvent.deltaY > 0;
      $('#canvas-body').panzoom('zoom', zoomOut, {
        increment: opts.options.canvas.scrollIncrement,
        focal: {
          clientX: e.clientX + CANVAS_SIZE/2,
          clientY: e.clientY + CANVAS_SIZE/2
        },
        animate: false
      });
    })
    // Alt-click zooming
    $('body').on('keydown', function(e) {
      if (e.target != this) return;
      if (e.keyCode == ALT_KEY || e.keyCode == ALT_KEY_FF) {
        var zoomOut = false;
        var zoomHandler = function (e) {
          // Don't zoom on right click or when clicking elements
          if (e.button == RIGHT_BUTTON || e.target != this) return;
          $('#canvas-body').panzoom('zoom', zoomOut, {
            focal: {
              clientX: e.clientX + CANVAS_SIZE/2,
              clientY: e.clientY + CANVAS_SIZE/2
            },
            animate: true
          });
        };
        var zoomOutHandler = function(e) {
          if (e.keyCode == SHIFT_KEY) {
            zoomOut = true;
            $('#canvas-body')
              .css('cursor', 'zoom-out')
              .css('cursor', '-webkit-zoom-out');
          }
        };
        var keyUpHandler = function(e) {
          if (e.keyCode == ALT_KEY  || e.keyCode == ALT_KEY_FF) {
            // Remove all listeners
            $('#canvas-body')
              .css('cursor', 'default')
              .off('mousedown', zoomHandler)
            $(this)
              .off('keydown', zoomOutHandler)
              .off('keyup', keyUpHandler);
          } else if (e.keyCode == SHIFT_KEY) {
            zoomOut = false;
            $('#canvas-body')
              .css('cursor', 'zoom-in')
              .css('cursor', '-webkit-zoom-in');
          }
        };

        // Set listeners
        $('#canvas-body')
          .css('cursor', 'zoom-in')
          .css('cursor', '-webkit-zoom-in')
          .on('mousedown', zoomHandler);
        $(this)
          .on('keydown', zoomOutHandler)
          .on('keyup', keyUpHandler);
      } else if (e.keyCode == SPACEBAR) {
        // Reset pan and zoom on spacebar press
        $('#canvas-body').panzoom('reset');
      }
    })
    // Fix contain dimensions upon browser window resize
    $(window).on('resize', function() {
      $('#canvas-body').panzoom('resetDimensions');
    });

  });

  self.on('update', function() {
    var selection = self.opts.selection.mapBy('view.domId');
    jsp.clearDragSelection();
    jsp.addToDragSelection(selection);
  });

  // RUN TEST
  // self.one('mount', function() {
  //   var Test = require('tests/CanvasTest')(this);
  //   ConnectionActions.connect('ws://localhost:9999', function() {
  //     Test.testAll(26,30);
  //   });
  // })
</studio-canvas>
