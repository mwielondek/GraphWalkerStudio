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
  var RiotControl   = require('app/RiotControl');
  var VertexActions = require('action/VertexActions');

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

  VertexActions.addChangeListener(function(vertices) {
    self.vertices = vertices
    self.update()
  })

  self.on('mount', function() {
    // Load vertices from model store. `getAll` will make the registered stores emit a change event,
    // together with a list of vertex objects, which in turn will trigger the change listener above.
    VertexActions.getAll()

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
