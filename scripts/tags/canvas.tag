<studio-canvas>
  <vertex each={ vertex, i in vertices } options={ parent.mergeVertexOptions(vertex) } />

  var self = this

  self.vertices = []

  self.defaults = {
    bg: "#FFFFFF"
  };
  self.settings = $.extend({}, self.defaults, self.opts.options);

  mergeVertexOptions(vertexObject) {
    return $.extend(true, {}, self.opts.options.vertex, vertexObject);
  }

  RiotControl.on('vertex_change', function(vertices) {
    self.vertices = vertices
    self.update()
  })

  addVertex(e) {
    var vertex = {
      view: {
        centerY: e.pageY - self.root.offsetTop,
        centerX: e.pageX - self.root.offsetLeft
      }
    }
    RiotControl.trigger('vertex_add', vertex)
  }

  self.on('mount', function() {
    // Load vertices from model store
    RiotControl.trigger('canvas_init')

    // Set up event listeners
    $(self.root)
      // Add new vertices on double click
      .on("dblclick", function(e) {
        if (e.target === this) self.addVertex(e);
      });

  });
</studio-canvas>
