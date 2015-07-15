<studio-canvas>
  <vertex each={ vertices } selection={ [parent.opts.selection.indexOf(id) != -1,
    parent.opts.selection.length] } onselect={ parent.opts.onselect }/>
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
        DropOptions: { hoverClass: 'drag-hover' },
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
        if (e.target == this) self.opts.onselect(0);
      });

  });

  self.on('update', function() {
    // TODO: figure out why it's triggered twice on selection
    var selection = self.opts.selection;
    jsp.clearDragSelection();
    jsp.addToDragSelection(selection);
  });
</studio-canvas>
