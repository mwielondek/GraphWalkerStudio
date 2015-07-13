<studio-canvas>
  <vertex each={ vertices } isselected={ parent.opts.selection.indexOf(id) != -1 }
    onselect={ parent.opts.onselect }/>
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
        PaintStyle : {
          lineWidth:3,
          strokeStyle: '#000000',
        },
        DragOptions : { cursor: "crosshair" },
        Endpoints : [ [ "Dot", { radius:3 } ], [ "Dot", { radius:3 } ] ],
        EndpointStyles : [{ fillStyle:"#225588" }, { fillStyle:"#558822" }]
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
      .on("dblclick", function(e) {
        if (e.target === this) self.addVertex(e);
      })
      // Deselect vertices on click
      .on("click", function(e) {
        if (e.target == this) self.opts.onselect(0);
      });

  });
</studio-canvas>
