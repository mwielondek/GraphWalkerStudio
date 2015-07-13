<studio-canvas>
  <vertex each={ vertices } isselected={ parent.opts.selection.indexOf(id) != -1 }
    onselect={ parent.opts.onselect }/>

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

  var self = this

  self.vertices = []

  addVertex(e) {
    // Prepare vertex object
    var vertex = {
      view: {
        centerY: e.pageY - self.root.offsetTop,
        centerX: e.pageX - self.root.offsetLeft
      }
    }
    // Dispatch action
    VertexActions.addVertex(vertex);
  }

  VertexActions.getAll(function(vertices) {
    self.vertices = vertices;
  });

  VertexActions.addChangeListener(function(vertices) {
    self.vertices = vertices
    self.update()
  })

  self.on('mount', function() {
    // Set as container for jsPlumb
    jsp.setContainer(this.root);
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
