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
      box-sizing: border-box;
      border: 7px solid #6e2d1f;
      background: #f0f0f0;
      position: absolute;
      height: 10000px;
      width: 10000px;
      top: -5000px;
      left: -5000px;
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
    $('#canvas-body').panzoom({
      cursor: 'default',
      contain: 'invert', // Don't show what's behind canvas
      onEnd: function() {
        // Store pan position in model
        ActionUtils.timeBufferedAction(function() {
          ModelActions.setProps(opts.model.id, {
            view: {
              panzoom: $(this).panzoom('getMatrix')
            }
          });
        }.bind(this), 'model.update.panzoom', 400);
      },
      $zoomIn: $('#zoom-in'),
      $zoomOut: $('#zoom-out'),
      $zoomRange: $('#zoom-range'),
      onZoom: function(e, pz, scale) {
        jsp.setZoom(scale);
      }
    })
    // Mousewheel zooming (doesn't support Firefox)
    .on('mousewheel', function( e ) {
      // Scroll while hovering over an element
      if (e.target != this) {
        // Find correct offsetParent
        var offsetParent = e.target;
        while (offsetParent.offsetParent != this) {
          offsetParent = offsetParent.offsetParent;
        }
        // Set focal point
        var clientX = offsetParent.offsetLeft;
        var clientY = offsetParent.offsetTop;
      };

      // Don't scroll container
      e.preventDefault();

      // Zoom in or out?
      var delta = e.delta || e.originalEvent.wheelDelta;
      var zoomOut = delta ? delta < 0 : e.originalEvent.deltaY > 0;

      $('#canvas-body').panzoom('zoom', zoomOut, {
        increment: 0.00005 * Math.max(Math.abs(delta), 50),
        focal: {
          clientX: clientX || e.originalEvent.layerX,
          clientY: clientY || e.originalEvent.layerY
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
            increment: 0.3,
            focal: {
              clientX: e.originalEvent.layerX,
              clientY: e.originalEvent.layerY
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
