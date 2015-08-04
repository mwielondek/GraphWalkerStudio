<studio-canvas class="{ highlight: !selection.length }">
  <div class="zoom-button" id="zoom-in">+</div>
  <div class="zoom-button" id="zoom-out">–</div>
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
      position: absolute;
      height: 10000px;
      width: 10000px;
      top: -5000px;
      left: -5000px;
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
        if (e.target === this) self.addVertex(e);
      })
      // Deselect vertices on click
      .on('click', function(e) {
        if (e.target == this) self.opts.selection.clear();
      })
      .on('mousedown', function(e) {
        // Create rubberband on left click-n-drag
        if (e.button == LEFT_BUTTON) {
          $(this).trigger('rubberband', e);
          e.stopImmediatePropagation();
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
      onZoom: function(e, pz, scale) {
        jsp.setZoom(scale);
      }
    });
    $(window).on('resize', function() {
      // Fix contain dimensions upon browser window resize
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
