<studio-canvas>
  <vertex each={ filterByModel(vertices) } isselected={ parent.opts.selection.mapBy('id').indexOf(id) != -1 }
  resizable={ parent.opts.selection.length == 1 } updateselection={ parent.opts.updateselection }/>
  <edge each={ filterByModel(edges) } isselected={ parent.opts.selection.mapBy('id').indexOf(id) != -1 }/>

  <style>
  studio-canvas {
    height: 100%;
    display: block;
    position: relative;
    margin-right: 310px;
    background-color: #f0f0f0;
  }
  </style>

  var $                 = require('jquery');
  var jsp               = require('jsplumb');
  var RiotControl       = require('app/RiotControl');
  var VertexActions     = require('actions/VertexActions');
  var EdgeActions       = require('actions/EdgeActions');
  var ElementConstants  = require('constants/ElementConstants');
  var ConnectionActions = require('actions/ConnectionActions');
  var rubberband        = require('utils/rubberband');

  var self = this

  self.vertices = []
  self.edges = []

  addVertex(e) {
    // Prepare vertex object
    var vertex = {
      modelId: opts.model.id,
      view: {
        centerY: e.pageY - self.root.offsetTop,
        centerX: e.pageX - self.root.offsetLeft
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
      jsp.setContainer(self.root);

      // Move connection creation logic to `edge` tag.
      jsp.bind('beforeDrop', function(params) {
        self.addEdge(params.sourceId, params.targetId);
        return false;
      });

      // Selecting edges
      jsp.bind('click', function(connection) {
        var edgeId = connection.getParameter('edge_id');
        self.opts.updateselection(edgeId, ElementConstants.T_EDGE);
      });
    });

    // Create a selection rubberband on click-n-drag
    rubberband(self.root, 'vertex', function(selectedVertices, append) {
      // Dispatch it to end of event queue so that it is not
      // overriden by the onClick handler below.
      setTimeout(function() {
        self.opts.updateselection(selectedVertices.map(function(el) {
          return el['_vertexId'];
        }), ElementConstants.T_VERTEX, append);
      }, 0);
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
      });

  });

  self.on('update', function() {
    var selection = self.opts.selection.mapBy('domId');
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
